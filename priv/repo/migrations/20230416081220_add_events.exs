defmodule Eren.Repo.Migrations.AddEvents do
  use Ecto.Migration

  def change do
    create table("events", primary_key: false, options: "WITHOUT ROWID, STRICT") do
      add :id, :blob, primary_key: true
      add :items, :text
    end
  end
end
