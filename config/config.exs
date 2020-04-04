# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_view_game,
  namespace: LiveGame

# Configures the endpoint
config :live_view_game, LiveGameWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VwARjamQpDO7Dwlra7TrGuKfsUR9Tpsn1wQXls6OGzx+UI0yk12ZB3B+Vh/6les0",
  render_errors: [view: LiveGameWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveGame.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "diSTv5gt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
