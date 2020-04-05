defmodule LiveGameWeb.Home do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGame.Presence
  require Logger

  @topic "arena"

  def mount(_params, session, socket) do
    # Subscribe to the topic
    Endpoint.subscribe(@topic)

    # Track changes to the topic
    Presence.track(
      self(),
      @topic,
      socket.id,
      %{
        user_id: session["id"]
      }
    )

    initial_count = Presence.list(@topic) |> map_size

    {:ok,
     assign(socket, %{
       player_count: initial_count,
       session_id: session["id"],
       users: get_user_names()
     })}
  end

  def get_user_names do
    Presence.list(@topic)
    |> Enum.map(fn {_user_id, data} ->
      data[:metas] |> List.first()
    end)
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{player_count: count}} = socket
      ) do
    Logger.info("Presence diff: #{joins} joins, #{leaves} leaves")

    player_count = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, player_count: player_count, users: get_user_names())}
  end
end
