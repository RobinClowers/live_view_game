defmodule LiveGameWeb.HomeView do
  use LiveGameWeb, :view
  alias LiveGame.Game

  def can_attack?(%{player_battle_pids: player_battle_pids}, current_user_id, player_id) do
    cond do
      current_user_id == player_id -> false
      player_battle_pids[player_id] -> false
      true -> true
    end
  end

  def character_image(socket, character) do
    img_tag(
      Routes.static_path(socket, "/images/#{character}.png"),
      alt: Game.character_descriptions()[character],
      title: character |> to_string |> String.capitalize()
    )
  end
end
