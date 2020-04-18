defmodule LiveGame.Game do
  use GenServer
  require Logger

  @initial_state %{
    players: %{},
    players_in_battle: %{}
  }

  def initial_state, do: @initial_state

  def start_link(state) do
    Logger.info("Starting game server: #{inspect(state)}")
    GenServer.start_link(__MODULE__, state, name: CurrentGame)
  end

  def init(state) do
    Logger.info("Init game server: #{inspect(state)}")
    {:ok, state}
  end

  def get_state do
    GenServer.call(CurrentGame, "get_state")
  end

  def update_state(state) do
    GenServer.call(CurrentGame, {"update_state", state})
  end

  def add_player(player) do
    GenServer.call(CurrentGame, {"add_player", player})
  end

  def attack(attacker_id, defender_id) do
    GenServer.call(CurrentGame, {"attack", attacker_id, defender_id})
  end

  def handle_call("get_state", _from, state) do
    Logger.info("Event get_state: #{inspect(state)}")
    {:reply, {:ok, state}, state}
  end

  def handle_call({"update_state", new_state}, _from, _state) do
    Logger.info("Event update_state: #{inspect(new_state)}")
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({"add_player", player}, _from, state) do
    Logger.info("Event add_player: #{inspect(player)}")
    players = Map.put(state.players, player.id, player)
    state = %{state | players: players}
    {:reply, {:ok, state}, state}
  end

  def handle_call(
        {"attack", attacker_id, defender_id},
        _from,
        %{players_in_battle: players_in_battle} = state
      ) do
    Logger.info("Event attack: #{inspect(attacker_id)}, #{inspect(defender_id)}")
    players_in_battle = Map.put(players_in_battle, attacker_id, defender_id)
    players_in_battle = Map.put(players_in_battle, defender_id, attacker_id)
    state = %{state | players_in_battle: players_in_battle}
    {:reply, {:ok, state}, state}
  end
end
