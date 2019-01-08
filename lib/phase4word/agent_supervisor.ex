defmodule Phase4word.AgentSupervisor do
  use DynamicSupervisor

  alias Phase4word.PlayerAgent

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {PlayerAgent, name})
  end

  def terminate_child(name) do
    # :ets.delete(name, )
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  defp pid_from_name(name) do
    name
    |> PlayerAgent.via_tuple()
    |> GenServer.whereis()
  end

end
