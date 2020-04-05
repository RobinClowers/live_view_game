defmodule LiveGame.Presence do
  use Phoenix.Presence,
    otp_app: :live_view_game,
    pubsub_server: LiveGame.PubSub
end
