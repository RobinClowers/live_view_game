defmodule LiveGameWeb.Home do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGame.Presence
  require Logger

  @topic "arena"

  @initial_state %{
    players: []
  }

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

    {:ok,
     assign(socket, %{
       state: @initial_state,
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
      "Presence diff (#{socket.assigns.user_id}): \njoins: #{inspect(joins)}, \nleaves: #{
        inspect(leaves)
      } "
    )

    {:noreply,
     assign(socket, %{
       player_count: Presence.count_users(@topic),
       users: Presence.list_users(@topic)
     })}
  end

  def handle_event("go", payload, socket) do
    Logger.info("Command: go, payload: #{inspect(payload)}")
    {:noreply, assign(socket, :state, socket.assigns.state)}
  end

  def handle_info(%{event: "update:state", payload: state}, socket) do
    {:noreply, assign(socket, :state, socket.assigns.state)}
  end
end
