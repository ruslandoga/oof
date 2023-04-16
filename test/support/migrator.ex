defmodule Migrator do
  @moduledoc """
  Migrates every :memory: SQLite3 database in a pool.
  """

  @doc "Lists migration modules for a repo"
  def migrations(repo) do
    path = Ecto.Migrator.migrations_path(repo)

    Path.join([path, "**", "*.exs"])
    |> Path.wildcard()
    |> Enum.map(fn file ->
      base = Path.basename(file)

      case Integer.parse(Path.rootname(base)) do
        {integer, "_" <> name} -> {integer, name, file}
        _ -> nil
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.sort()
    |> Enum.map(fn {version, _, file} when is_binary(file) ->
      loaded_modules = file |> Code.compile_file() |> Enum.map(&elem(&1, 0))

      mod =
        Enum.find(loaded_modules, fn mod ->
          function_exported?(mod, :__migration__, 0)
        end)

      if mod do
        {version, mod}
      else
        raise Ecto.MigrationError,
              "file #{Path.relative_to_cwd(file)} does not define an Ecto.Migration"
      end
    end)
  end

  @doc "Prepares for migration, best to be called in :after_connect callback"
  def prepare(config) do
    Enum.each(config, fn {k, v} -> Process.put(k, v) end)
  end

  @doc false
  def get_dynamic_repo do
    repo = Process.get(:repo) || raise "missing :repo in config"
    repo.get_dynamic_repo()
  end

  @doc false
  def __adapter__, do: __MODULE__

  @doc false
  def execute_ddl(_meta, definition, opts) do
    conn = Process.get(:conn) || raise "missing :conn in config"
    opts = Keyword.delete(opts, :log)

    ddl_logs =
      definition
      |> Ecto.Adapters.SQLite3.Connection.execute_ddl()
      |> List.wrap()
      |> Enum.map(&Exqlite.query!(conn, &1, [], opts))
      |> Enum.flat_map(&Ecto.Adapters.SQLite3.Connection.ddl_logs/1)

    {:ok, ddl_logs}
  end
end
