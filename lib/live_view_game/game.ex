defmodule LiveGame.Game do
  use GenServer
  require Logger
  alias LiveGame.Game
  alias LiveGame.Battle
  alias LiveGame.Player

  defstruct players: %{}, player_battle_pids: %{}

  @character_descriptions %{
    chimera: "A chimera",
    gigas: "A floating humanoid"
  }

  def initial_state, do: %Game{}
  def character_descriptions, do: @character_descriptions

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

  def handle_call("get_state", _from, state) do
    Logger.info("Event get_state: #{inspect(state)}")
    {:reply, {:ok, state}, state}
  end

  def update_state(state) do
    GenServer.call(CurrentGame, {"update_state", state})
  end

  def handle_call({"update_state", new_state}, _from, _state) do
    Logger.info("Event update_state: #{inspect(new_state)}")
    {:reply, {:ok, new_state}, new_state}
  end

  def add_player(player) do
    GenServer.call(CurrentGame, {"add_player", player})
  end

  def handle_call({"add_player", %Player{} = player}, _from, state) do
    Logger.info("Event add_player: #{inspect(player)}")
    players = Map.put(state.players, player.id, player)
    state = %{state | players: players}
    {:reply, {:ok, state}, state}
  end

  def start_battle(attacker_id, defender_id) do
    GenServer.call(CurrentGame, {"start_battle", attacker_id, defender_id})
  end

  def handle_call(
        {"start_battle", attacker_id, defender_id},
        _from,
        %{player_battle_pids: player_battle_pids, players: players} = state
      ) do
    Logger.info("Event start_battle: #{inspect(attacker_id)}, #{inspect(defender_id)}")

    {:ok, pid} = Battle.start(players, attacker_id, defender_id)

    player_battle_pids = Map.put(player_battle_pids, attacker_id, pid)
    player_battle_pids = Map.put(player_battle_pids, defender_id, pid)
    state = update_in(state.players[attacker_id].in_battle, fn _ -> true end)
    state = update_in(state.players[defender_id].in_battle, fn _ -> true end)
    state = %{state | player_battle_pids: player_battle_pids}
    {:reply, {:ok, state}, state}
  end

  def exit_battle(user_id) do
    Logger.info("Event exit_battle: #{user_id}")
    GenServer.call(CurrentGame, {"exit_battle", user_id})
  end

  def handle_call({"exit_battle", user_id}, _from, state) do
    state = update_in(state.players[user_id].in_battle, fn _ -> false end)
    state = update_in(state.player_battle_pids, &(&1 |> Map.drop([user_id])))
    LiveGameWeb.Endpoint.broadcast(LiveGameWeb.Home.topic(), "update:state", state)
    {:reply, :ok, state}
  end
end
