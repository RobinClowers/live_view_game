defmodule LiveGameWeb.BattleView do
  use LiveGameWeb, :view
  alias LiveGameWeb.Router.Helpers, as: Routes
  alias LiveGame.Game

  def character_image(socket, character, direction) do
    style =
      cond do
        direction == :left && character == "chimera" -> "transform: scaleX(-1);"
        direction == :right && character == "gigas" -> "transform: scaleX(-1);"
        true -> ""
      end

    img_tag(Routes.static_path(socket, "/images/#{character}.png"),
      alt: Game.character_descriptions()[character],
      width: "80px",
      style: style
    )
  end
end
