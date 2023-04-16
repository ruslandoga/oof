defmodule Eren.EventsTest do
  use Eren.DataCase, async: true

  alias Eren.Events
  alias Eren.Events.Event

  describe "decode_envelop/1" do
    # examples from https://develop.sentry.dev/sdk/envelopes/

    test "header-only" do
      envelop = ~s[{"event_id":"12c2d058d58442709aa2eca08bf20986"}]

      assert Events.decode_envelop(envelop) == %{
               "event_id" => "12c2d058d58442709aa2eca08bf20986",
               "items" => []
             }
    end

    test "envelop with 2 items" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc","dsn":"https://e12d836b15bb49d7bbf99e64295d995b:@sentry.io/42"}
      {"type":"attachment","length":10,"content_type":"text/plain","filename":"hello.txt"}
      \xef\xbb\xbfHello\r\n
      {"type":"event","length":41,"content_type":"application/json","filename":"application.log"}
      {"message":"hello world","level":"error"}
      """

      assert Events.decode_envelop(envelop) ==
               %{
                 "dsn" => "https://e12d836b15bb49d7bbf99e64295d995b:@sentry.io/42",
                 "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
                 "items" => [
                   %{
                     "content_type" => "text/plain",
                     "filename" => "hello.txt",
                     "length" => 10,
                     "payload" => "\uFEFFHello\r",
                     "type" => "attachment"
                   },
                   %{
                     "content_type" => "application/json",
                     "filename" => "application.log",
                     "length" => 41,
                     "payload" => %{"level" => "error", "message" => "hello world"},
                     "type" => "event"
                   }
                 ]
               }
    end

    test "envelope with 2 Items, last newline omitted" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc","dsn":"https://e12d836b15bb49d7bbf99e64295d995b:@sentry.io/42"}
      {"type":"attachment","length":10,"content_type":"text/plain","filename":"hello.txt"}
      \xef\xbb\xbfHello\r\n
      {"type":"event","length":41,"content_type":"application/json","filename":"application.log"}
      {"message":"hello world","level":"error"}\
      """

      assert Events.decode_envelop(envelop) ==
               %{
                 "dsn" => "https://e12d836b15bb49d7bbf99e64295d995b:@sentry.io/42",
                 "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
                 "items" => [
                   %{
                     "content_type" => "text/plain",
                     "filename" => "hello.txt",
                     "length" => 10,
                     "payload" => "\uFEFFHello\r",
                     "type" => "attachment"
                   },
                   %{
                     "content_type" => "application/json",
                     "filename" => "application.log",
                     "length" => 41,
                     "payload" => %{"level" => "error", "message" => "hello world"},
                     "type" => "event"
                   }
                 ]
               }
    end

    test "envelope with 2 empty attachments" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc"}
      {"type":"attachment","length":0}

      {"type":"attachment","length":0}
      """

      assert Events.decode_envelop(envelop) == %{
               "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
               "items" => [
                 %{
                   "length" => 0,
                   "payload" => "",
                   "type" => "attachment"
                 },
                 %{
                   "length" => 0,
                   "payload" => "",
                   "type" => "attachment"
                 }
               ]
             }
    end

    test "envelope with 2 empty attachments, last newline omitted" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc"}
      {"type":"attachment","length":0}

      {"type":"attachment","length":0}\
      """

      assert Events.decode_envelop(envelop) == %{
               "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
               "items" => [
                 %{
                   "length" => 0,
                   "payload" => "",
                   "type" => "attachment"
                 },
                 %{
                   "length" => 0,
                   # TODO
                   # "payload" => "",
                   "type" => "attachment"
                 }
               ]
             }
    end

    test "item with implicit length, terminated by newline" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc"}
      {"type":"attachment"}
      helloworld
      """

      assert Events.decode_envelop(envelop) == %{
               "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
               "items" => [
                 %{
                   "type" => "attachment",
                   "payload" => "helloworld"
                 }
               ]
             }
    end

    test "item with implicit length, last newline omitted, terminated by EOF" do
      envelop = """
      {"event_id":"9ec79c33ec9942ab8353589fcb2e04dc"}
      {"type":"attachment"}
      helloworld\
      """

      assert Events.decode_envelop(envelop) == %{
               "event_id" => "9ec79c33ec9942ab8353589fcb2e04dc",
               "items" => [
                 %{
                   "type" => "attachment",
                   "payload" => "helloworld"
                 }
               ]
             }
    end

    test "envelope without headers, implicit length, last newline omitted, terminated by EOF" do
      envelop = """
      {}
      {"type":"session"}
      {"started": "2020-02-07T14:16:00Z","attrs":{"release":"sentry-test@1.0.0"}}\
      """

      assert Events.decode_envelop(envelop) == %{
               "items" => [
                 %{
                   "type" => "session",
                   "payload" => %{
                     "started" => "2020-02-07T14:16:00Z",
                     "attrs" => %{
                       "release" => "sentry-test@1.0.0"
                     }
                   }
                 }
               ]
             }
    end
  end

  describe "insert_event/1" do
    test "without id" do
      items = [
        %{
          "type" => "session",
          "payload" => %{
            "started" => "2020-02-07T14:16:00Z",
            "attrs" => %{
              "release" => "sentry-test@1.0.0"
            }
          }
        }
      ]

      event = %{"items" => items}
      assert {:ok, %Event{id: <<_::16-bytes>> = id, items: ^items}} = Events.insert_event(event)
      assert %Event{id: ^id, items: ^items} = Repo.get!(Event, id)
    end

    test "with id" do
      event_id = "9ec79c33ec9942ab8353589fcb2e04dc"
      items = [%{"type" => "attachment", "payload" => "helloworld"}]
      event = %{"event_id" => event_id, "items" => items}

      assert {:ok, %Event{id: <<_::16-bytes>> = id, items: ^items}} = Events.insert_event(event)
      assert id == Base.decode16!(event_id, case: :lower)
      assert %Event{id: ^id, items: ^items} = Repo.get!(Event, id)
    end

    test "without items" do
      event = %{"event_id" => "12c2d058d58442709aa2eca08bf20986"}
      assert {:error, changeset} = Events.insert_event(event)
      assert errors_on(changeset) == %{items: ["can't be blank"]}
    end
  end
end
