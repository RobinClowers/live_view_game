defmodule LiveGameWeb.Home do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGameWeb.Battle
  alias LiveGame.Presence
  alias LiveGame.Game
  alias LiveGame.Player
  alias LiveGameWeb.Router.Helpers, as: Routes
  require Logger

  @topic "arena"

  def render(assigns) do
    Phoenix.View.render(LiveGameWeb.HomeView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    Endpoint.subscribe(@topic)

    Presence.track(
      self(),
      @topic,
      socket.id,
      %{
        user_id: session["id"]
      }
    )

    {:ok, state} = LiveGame.Game.get_state()
    Logger.info("Loading game state: #{inspect(state)}")

    {:ok,
     assign(socket, %{
       player_changeset: Player.new(),
       state: state,
       player: state.players[session["id"]],
       player_count: Presence.count_users(@topic),
       user_id: session["id"]
     })}
  end

  def topic, do: @topic

  def exit_battle(user_id) do
    GenServer.cast("exit_battle", user_id)
  end

  # Example payload
  # %{
  #   joins: %{"123" => %{metas: [%{status: "away", phx_ref: ...}]},
  #   leaves: %{"456" => %{metas: [%{status: "online", phx_ref: ...}]
  # },
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: assigns} = socket
      ) do
    Logger.info(
      "Presence diff (#{assigns.user_id}): \njoins: #{inspect(joins)}, \nleaves: #{
        inspect(leaves)
      } "
    )

    {:noreply,
     assign(socket, %{
       state: assigns.state,
       player_count: Presence.count_users(@topic)
     })}
  end

  def handle_info(%{event: "update:state", payload: state}, socket) do
    Logger.info("Event (#{socket.assigns.user_id}): update:state, payload: #{inspect(state)}")
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(
        %{event: "defend", payload: %{attacker_id: attacker_id, defender_id: defender_id}},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    if defender_id == user_id do
      {:noreply,
       push_redirect(socket,
         to: Routes.live_path(socket, Battle, attacker_id: attacker_id, defender_id: defender_id)
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("new_player", payload, socket) do
    Logger.info("Command: new_player, payload: #{inspect(payload)}")
    player = Player.new(payload["player"])

    if player.valid? do
      Logger.info("Player added: #{inspect(player.changes)}")

      {:ok, state} = Game.add_player(struct(Player, player.changes))
      Endpoint.broadcast_from(self(), @topic, "update:state", state)

      {:noreply,
       assign(socket,
         player: player.changes,
         changeset: player,
         state: state
       )}
    else
      Logger.info("Player validation failed: #{inspect(player.errors)}")
      {:noreply, assign(socket, player_changeset: %{player | action: :insert})}
    end
  end

  def handle_event("start_battle", %{"id" => defender_id} = payload, %{assigns: assigns} = socket) do
    Logger.info("Event start_battle: #{inspect(payload)}")
    {:ok, state} = Game.start_battle(assigns.user_id, defender_id)
    Endpoint.broadcast_from(self(), @topic, "update:state", state)

    Endpoint.broadcast_from(self(), @topic, "defend", %{
      attacker_id: assigns.user_id,
      defender_id: defender_id
    })

    {:noreply,
     push_redirect(socket,
       to:
         Routes.live_path(socket, Battle, attacker_id: assigns.user_id, defender_id: defender_id)
     )}
  end

  def handle_info("exit_battle", _payload, socket) do
    {:noreply, socket}
  end
end
