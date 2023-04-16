defmodule Eren.Events.Event do
  @moduledoc false
  use Ecto.Schema

  @primary_key false
  schema "events" do
    field :id, :binary, primary_key: true
    field :items, {:array, :map}
  end
end
