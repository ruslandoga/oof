defmodule Oof.Repo do
  use Ecto.Repo,
    otp_app: :oof,
    adapter: Ecto.Adapters.SQLite3
end
