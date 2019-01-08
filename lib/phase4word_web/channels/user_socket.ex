defmodule Phase4wordWeb.UserSocket do
  use Phoenix.Socket
  alias Phase4word.Hash

  ## Channels
  # channel "room:*", Phase4wordWeb.RoomChannel
  channel "global:phase4", Phase4wordWeb.Chunnel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"pub_key" => pub_key, "sign" => sign}, socket) do
  #  case Phoenix.Token.verify(socket, "salt", token, max_age: 86400) do ->
    case Registry.lookup(Registry.PlayerAgent, name = Hash.h(pub_key, 1)) do
      [{_pid, _name}] ->
        IO.puts({pub_key, sign, "found sup"})
        {:ok, assign(socket, :pub_key, pub_key)}
      [] ->
        IO.puts({pub_key, sign, "making sup"})
        Phase4word.AgentSupervisor.start_child(name)
        {:ok, assign(socket, :pub_key, pub_key)}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Phase4wordWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
