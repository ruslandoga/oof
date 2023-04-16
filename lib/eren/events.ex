defmodule Eren.Events do
  @moduledoc "Processing for events coming from Sentry clients"
  alias __MODULE__.Event

  @doc """
  Decodes [Sentry Envelopes](https://develop.sentry.dev/sdk/envelopes/)
  """
  def decode_envelop(envelop) when is_binary(envelop) do
    {acc, _} =
      envelop
      |> String.splitter("\n")
      |> Enum.reduce({[], :header}, fn
        header, {[], :header} ->
          {[Jason.decode!(header)], :header}

        "", {_acc, :header} = acc ->
          acc

        header, {acc, :header} ->
          {[Jason.decode!(header) | acc], :payload}

        payload, {[header | acc], :payload} ->
          {[Map.put(header, "payload", decode_payload(header, payload)) | acc], :header}
      end)

    [header | items] = :lists.reverse(acc)
    Map.put(header, "items", items)
  end

  defp decode_payload(%{"type" => "event"}, event), do: Jason.decode!(event)
  defp decode_payload(%{"type" => "session"}, session), do: Jason.decode!(session)
  defp decode_payload(%{"type" => "attachment"}, attachment), do: attachment

  def insert_event(event) do
    event
    |> event_changeset()
    |> Eren.Repo.insert()
  end

  def event_changeset(event) do
    import Ecto.Changeset

    %Event{}
    |> cast(ensure_id(event), [:id, :items])
    |> validate_required([:id, :items])
  end

  defp ensure_id(%{"event_id" => id} = event) do
    Map.put(event, "id", Base.decode16!(id, case: :lower))
  end

  defp ensure_id(event), do: Map.put(event, "id", Ecto.UUID.bingenerate())
end
