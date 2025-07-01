defmodule Stackoverflow.ResultCache do
  @moduledoc """
  Simple ETS-based cache for storing search and AI-sorted results.
  """
  use GenServer

  @table :result_cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    ensure_table()
    {:ok, %{}}
  end

  defp ensure_table do
    case :ets.info(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :public, :set, {:read_concurrency, true}])
      _ -> :ok
    end
  end

  def put(token, data) do
    ensure_table()
    :ets.insert(@table, {token, data})
    :ok
  end

  def get(token) do
    ensure_table()
    case :ets.lookup(@table, token) do
      [{^token, data}] -> data
      _ -> nil
    end
  end

  def delete(token) do
    ensure_table()
    :ets.delete(@table, token)
    :ok
  end
end
