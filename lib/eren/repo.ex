defmodule Eren.Repo do
  use Ecto.Repo,
    otp_app: :eren,
    adapter: Ecto.Adapters.SQLite3
end
