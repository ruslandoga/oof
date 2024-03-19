import Config

# Configure your database
config :oof, Oof.Repo,
  database: ":memory:",
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :oof, OofWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "w3k4wBGdgBLSdk/krE72/BlCjKS7NK5Zr1mlU+K7a6GKLJ2Fe5CagDG+ByHHClKx",
  server: false

# In test we don't send emails.
config :oof, Oof.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
