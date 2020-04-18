defmodule LiveGameWeb.HomeView do
  use LiveGameWeb, :view

  def can_attack?(%{players_in_battle: players_in_battle}, current_user_id, player_id) do
    cond do
      current_user_id == player_id -> false
      players_in_battle[player_id] -> false
      true -> true
    end
  end
end
