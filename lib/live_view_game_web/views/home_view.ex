defmodule LiveGameWeb.HomeView do
  use LiveGameWeb, :view

  def can_attack?(%{player_battle_pids: player_battle_pids}, current_user_id, player_id) do
    cond do
      current_user_id == player_id -> false
      player_battle_pids[player_id] -> false
      true -> true
    end
  end
end
