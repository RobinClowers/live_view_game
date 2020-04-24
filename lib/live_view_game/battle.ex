defmodule LiveGame.Battle do
  use GenServer
  require Logger
  alias LiveGame.Attack
  alias LiveGame.Battle

  defstruct players: %{},
            log: [],
            attacker_id: nil,
            winner_id: :none,
            active_player_id: nil,
            attack_type: nil,
            defense_type: nil

  def start(players, attacker_id, defender_id) do
    %Battle{
      players: Map.take(players, [attacker_id, defender_id]),
      attacker_id: attacker_id,
      active_player_id: attacker_id
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

  def attack(pid, type) do
    GenServer.call(pid, {"attack", type})
  end

  def handle_call({"attack", type}, _from, state) do
    Logger.info("Event attack: type: #{type}")

    state = %{state | attack_type: type} |> resolve_attack
    {:reply, {:ok, state}, state}
  end

  def defend(pid, type, player) do
    GenServer.call(pid, {"defend", type, player})
  end

  def handle_call({"defend", type, player}, _from, state) do
    Logger.info("Event defend: type: #{type}, player: #{inspect(player)}")

    state = %{state | defense_type: type} |> resolve_attack
    {:reply, {:ok, state}, state}
  end

  def resolve_attack(%{attack_type: nil} = state), do: state
  def resolve_attack(%{defense_type: nil} = state), do: state

  def resolve_attack(state) do
    state
    |> damage_defender
    |> broadcast
  end

  def damage_defender(
        %{attack_type: attack, defense_type: defense, active_player_id: attacker_id} = state
      ) do
    attacker = state.players[attacker_id]
    defender = defending_player(state)
    attack = Attack.execute(attack, defense, 4 + round(4 * :rand.uniform()))
    hp = defender.hp - attack.total_damage
    defender = %{defender | hp: hp}

    log = Attack.log(attack, attacker.name, defender.name) ++ state.log

    if hp <= 0 do
      %{
        state
        | winner_id: attacker_id,
          log: ["#{attacker.name} is the winner!" | log],
          players: %{attacker.id => attacker, defender.id => defender}
      }
    else
      %{
        state
        | players: %{attacker.id => attacker, defender.id => defender},
          log: log,
          active_player_id: defender.id,
          defense_type: nil,
          attack_type: nil
      }
    end
  end

  def defending_player(%{active_player_id: active, players: players}) do
    players
    |> Map.values()
    |> Enum.find(fn player -> player.id != active end)
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
