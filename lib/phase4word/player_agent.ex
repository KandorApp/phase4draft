defmodule Phase4word.PlayerAgent do
  alias __MODULE__
  alias Phase4word.Hash
  use Agent




  # addr:: sha256(name), name:: sha256(pub_key), pub_key:: key,
  # green, mply_counter, scroll_counter :: Number,
  # comm_shared_keys :: %{name: key} where key = name ^^^ name ^^^

  defstruct addr: "", pub_key: "", green: 0, notes: []

  #######
  # API #
  #######

  # start_link with name a registered name equal to sha256(pub_key)
  # TODO: how is pub_key securely passed to PlayerAgent?


  def start_link(name) do
    Agent.start_link(fn -> %PlayerAgent{} end, name: {:global, name})
  end

  def get_notes(name) do
    Agent.get(name, fn state -> state.notes end)
  end

  def get_addr(name) do
    Agent.get(name, fn state -> state.addr end)
  end

  def mply(name, note) do
    #syntax help needed here
    Agent.update(name, fn state -> %{state | notes: state.notes ++ note} end)
    send name, {:mply, note}
  end



 ## TODO: refactor all agent functions to mfa style
  def receive_green(name, g) do
    Agent.update(name, fn state -> %{state | green: state.green + g} end)
  end

  def subscribe(name, topic) do
    Phoenix.PubSub.subscribe(name, self(), topic)
  end

  #############
  # Callbacks #
  #############

  def init(name) do
    send self(), {:set_state, name}
    {:ok, %PlayerAgent{}}
  end

  def handle_info({:set_state, name}, _state_data) do
    state = fresh_state(name)
    {:noreply, state}
  end

  def handle_info({:mply, note}, _from, state) do
    {:ok, note} = Poison.decode(note)
    restate = %{state | green: state.green + note.green,
                        notes: state.notes ++ note}


'''
    if source != state.addr do
      enc_note = ecdecrypt(note, state.pub_key) |> Poison.decodeJson
      p_note = decrypt_fields(enc_note)
      note_hash = sha256(note)

      Map.put(state, notes, {note_hash, p_note})
      for {agent, key} <- state.comm_shared_keys do
        e_note = e_chacha(p_note, key)
        send(agent, e_note)
      end

      PoolSupervisor.start_child(note_hash)
      Pool.route(note_hash, [note, destination])


    end
'''
    {:noreply, restate}
  end
'''
  def handle_info(:scrolled, _from, state) do
    %{state | scroll_counter: state.scroll_counter + 1,
              green: state.green * (state.mply_counter / (state.scroll_counter + 1))}
  end
'''
  defp fresh_state(name) do
    #create a new private table with table name = process registered name
    table = :ets.new(name, [:set, :private, :named_table])
    state = %PlayerAgent{addr: Hash.h(name, 1), pub_key: nil, green: 0}
    :ets.insert(table, {:player_agent, state})

  end

'''
  defp retrieve_state_from_file(name) do


    nonce_path = "/nonces/"
    nonce = File.open(nonce_path <> name)
    path = "/bins/"
    key = Map.get(%Phoenix.Socket.Message{}, "key")
    state = File.open(path <> name)
            |> chacha(key, nonce)
            |> :erlang.binary_to_term()

   %PlayerAgent{name: name, addr: state.addr, pub_key: key,
                green: state.green, notes: state.notes}
  end

'''

  def decrypt_fields(note) do
    ssi = note.ssi
    addr = note.addr
    signature = chacha(note.signature, Hash.h(addr, 1), ssi)
    spacetime = chacha(note.spacetime, Hash.h(signature, 1), ssi)
    data = chacha(note.data, Hash.h(spacetime, 1), ssi)
    meta = chacha(note.meta, Hash.h(data, 1), ssi)
    %{ssi: ssi, addr: addr, signature: signature, spacetime: spacetime,
      data: data, meta: meta}
  end



  defp chacha(input, key, nonce) do
    Chacha20.crypt(input, key, nonce)
  end

  defp ecdecrypt(data, key) do
    curve = :secp256r1
    :crypto.public_decrypt()
  end

  defp rsa_keygen do
    {[e, pub], [e | priv]} = :crypto.generate_key(:rsa, {4096, 65537})
  end
'''
  def start_cs(name) do
    Phase4.CommSupervisor.start_child(name)
  end
'''
  def via_tuple(name), do: {:via, Registry, {Registry.PlayerAgent, name}}
end
