defmodule Phase4wordWeb.Chunnel do
  use Phoenix.Channel
  alias Phase4word.PlayerAgent
  require Logger

  intercept ["mply"]
  
  def join("global:phase4", message, socket) do
    #Process.flag(:trap_exit, true)
    #name = %PlayerAgent{}.name
    #PlayerAgent.subscribe(name, "global:phase4")
    :timer.send_interval(5000, :ping)
    send(self(), {:after_join, message})

    {:ok, socket}
  end

  '''
  def join("global:" <> agent, message, socket) do
    #Process.flag(:trap_exit, true)
    #:timer.send_interval(5000, :ping)
    #name = %PlayerAgent{}.name
    #PlayerAgent.subscribe(name, "global:" <> subtopic)

    PlayerAgent.join(agent, message)
    send(self(), {:after_join, message})
    {:ok, socket}
  end
  '''


  def handle_info({:after_join, msg}, socket) do
    {:noreply, socket}
  end


  def handle_in("mply", %{"agent" => agent, "note" => note}, socket) do
    PlayerAgent.mply(agent, note)
  end

'''
  def handle_out("mply", %{"source" => source, "paname" => name, "g" => g, "note" => note}, socket) do
    if source == sha256(name) do
      PlayerAgent.receive_green(name, g)
      push socket, "mply", %{note: note}
    end
  end
  '''



  #def handle_info(:ping, socket) do
  #end


end
