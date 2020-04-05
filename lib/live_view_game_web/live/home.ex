defmodule LiveGameWeb.Home do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGame.Presence
  alias LiveGame.Game
  require Logger

  @topic "arena"

  def render(assigns) do
    assigns = Map.put(assigns, :player_changeset, Player.new())
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
       state: state,
       player: state.players[session["id"]],
       player_count: Presence.count_users(@topic),
       user_id: session["id"],
       users: Presence.list_users(@topic)
     })}
  end

  # Example paylod
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
       player_count: Presence.count_users(@topic),
       users: Presence.list_users(@topic)
     })}
  end

  def handle_info(%{event: "update:state", payload: state}, socket) do
    Logger.info("Event (#{socket.assigns.user_id}): update:state, payload: #{inspect(state)}")
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("new_player", payload, %{assigns: %{state: state}} = socket) do
    Logger.info("Command: new_player, payload: #{inspect(payload)}")
    player = Player.new(payload["player"])

    if player.valid? do
      Logger.info("Player added: #{inspect(player.changes)}")

      {:ok, state} = Game.add_player(player.changes)
      Endpoint.broadcast_from(self(), @topic, "update:state", state)

      {:noreply,
       assign(socket,
         player: player.changes,
         changeset: player,
         state: state
       )}
    else
      Logger.info("Player validation failed: #{inspect(player.errors)}")
      {:noreply, assign(socket, changeset: player)}
    end
  end
end
