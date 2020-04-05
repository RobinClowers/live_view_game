defmodule LiveGame.Presence do
  use Phoenix.Presence,
    otp_app: :live_view_game,
    pubsub_server: LiveGame.PubSub

  alias LiveGame.Presence

  def update_presence(pid, topic, key, payload) do
    metas =
      Presence.get_by_key(topic, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(pid, topic, key, metas)
  end

  def list_users(topic) do
    Presence.list(topic)
    |> Enum.map(fn {_user_id, data} ->
      data[:metas]
      |> List.first()
    end)
  end

  def count_users(topic) do
    topic |> Presence.list() |> map_size
  end
end
