defmodule LiveGame.Battle do
  use GenServer
  require Logger
  alias LiveGame.Game
  alias LiveGame.Battle

  def start(players, attacker_id, defender_id) do
    %{
      players: Map.take(players, [attacker_id, defender_id]),
      attacker_id: attacker_id,
      winner: :none
    }
    |> Battle.start_link()
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Logger.info("Init battle server: #{inspect(state)}")
    {:ok, state}
  end

  def attack(pid, attacker, defender) do
    GenServer.call(pid, {"attack", attacker, defender})
  end

  def handle_call({"attack", attacker, defender}, _from, state) do
    Logger.info("Event attack: attacker: {inspect(attacker)}, defender: #{inspect(defender)}")
    state = damage_player(attacker, defender, round(5 * :rand.uniform()), state)

    {:reply, {:ok, state}, state}
  end

  def damage_player(attacker, defender, damage, state) do
    hp = defender.hp - damage
    defender = %{defender | hp: hp}

    if hp < 0 do
      state =
        %{
          state
          | winner: attacker,
            players: %{attacker.id => attacker, defender.id => defender}
        }
        |> Battle.broadcast()

      state
    else
      Battle.broadcast(%{state | players: %{attacker.id => attacker, defender.id => defender}})
    end
  end

  def broadcast(state) do
    LiveGameWeb.Endpoint.broadcast(LiveGameWeb.Battle.topic(self()), "update:battle:state", state)
    state
  end

  def get_state(pid) do
    GenServer.call(pid, "get_state")
  end

  def handle_call("get_state", _from, state) do
    Logger.info("Event get_state: #{inspect(state)}")
    {:reply, {:ok, state}, state}
  end
end
