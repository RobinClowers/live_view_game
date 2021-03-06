defmodule LiveGameWeb.Battle do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGameWeb.Home
  alias LiveGame.Game
  alias LiveGame.Battle
  alias LiveGameWeb.Router.Helpers, as: Routes
  require Logger

  def render(assigns) do
    Phoenix.View.render(LiveGameWeb.BattleView, "index.html", assigns)
  end

  def mount(%{"attacker_id" => attacker_id, "defender_id" => defender_id}, session, socket) do
    {:ok, %{player_battle_pids: battle_pids, players: players} = state} = Game.get_state()
    Logger.info("Loaded game state: #{inspect(state)}")
    user_id = session["id"]
    battle_pid = battle_pids[user_id]

    if !players[attacker_id] || !players[defender_id] do
      {:ok, push_redirect(socket, to: Routes.live_path(socket, Home, %{}))}
    else
      {:ok, battle} = Battle.get_state(battle_pid)
      Logger.info("Loaded battle state: #{inspect(battle)}")

      topic = topic(battle_pid)
      Endpoint.subscribe(topic)

      socket =
        socket
        |> assign(%{
          is_attacker: attacker_id == user_id,
          user_id: user_id,
          battle_pid: battle_pid,
          attacker_id: attacker_id,
          defender_id: defender_id
        })

      {:ok, destructure_assign(socket, state, battle)}
    end
  end

  def destructure_assign(%{assigns: %{user_id: user_id}} = socket, state, battle) do
    Logger.info("player: #{inspect(battle.players[user_id])}")

    opponent =
      battle.players
      |> Map.values()
      |> Enum.find(fn player -> player.id != user_id end)

    assign(socket, %{
      state: state,
      log: battle.log,
      winner_id: battle.winner_id,
      player: battle.players[user_id],
      my_turn: battle.active_player_id == user_id,
      defense_type: battle.defense_type,
      attack_type: battle.attack_type,
      opponent: opponent
    })
  end

  def handle_info(%{event: "update:battle:state", payload: battle}, %{assigns: assigns} = socket) do
    Logger.info(
      "Event (#{socket.assigns.user_id}): update:battle:state, payload: #{inspect(battle)}"
    )

    {:noreply, destructure_assign(socket, assigns.state, battle)}
  end

  def handle_event("attack", %{"type" => type} = payload, socket) do
    Logger.info("Event attack: #{inspect(payload)}")

    %{assigns: %{state: state, battle_pid: battle_pid}} = socket

    {:ok, battle} = Battle.attack(battle_pid, type)

    {:noreply, destructure_assign(socket, state, battle)}
  end

  def handle_event("defend", %{"type" => type} = payload, socket) do
    Logger.info("Event defend: #{inspect(payload)}")

    %{assigns: %{player: player, state: state, battle_pid: battle_pid}} = socket

    {:ok, battle} = Battle.defend(battle_pid, type, player)

    {:noreply, destructure_assign(socket, state, battle)}
  end

  def handle_event(
        "exit",
        _payload,
        %{assigns: %{user_id: user_id, battle_pid: battle_pid}} = socket
      ) do
    Logger.info("Event exit for #{inspect(battle_pid)}")
    :ok = Game.exit_battle(user_id)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, Home))}
  end

  def topic(pid), do: "battle#{inspect(pid)}"
end
