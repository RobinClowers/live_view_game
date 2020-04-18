defmodule LiveGameWeb.Battle do
  use Phoenix.LiveView
  alias LiveGameWeb.Endpoint
  alias LiveGameWeb.Home
  alias LiveGame.Presence
  alias LiveGame.Game
  alias LiveGameWeb.Router.Helpers, as: Routes
  require Logger

  def render(assigns) do
    Phoenix.View.render(LiveGameWeb.BattleView, "index.html", assigns)
  end

  def mount(%{"attacker_id" => attacker_id, "defender_id" => defender_id}, session, socket) do
    {:ok, state} = LiveGame.Game.get_state()
    Logger.info("Loading game state: #{inspect(state)}")
    attacker = state.players[attacker_id]
    defender = state.players[defender_id]

    if !attacker || !defender do
      {:ok, push_redirect(socket, to: Routes.live_path(socket, Home, %{}))}
    else
      {:ok,
       assign(socket, %{
         state: state,
         player: state.players[session["id"]],
         user_id: session["id"],
         attacker: state.players[attacker_id],
         defender: state.players[defender_id]
       })}
    end
  end
end
