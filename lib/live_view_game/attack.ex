defmodule LiveGame.Attack do
  alias LiveGame.Attack

  defstruct attack: nil, defense: nil, multiplier: nil, base_damage: nil, total_damage: nil

  def execute(attack, defense, damage) do
    %Attack{attack: attack, defense: defense, base_damage: damage}
    |> apply_multiplier
    |> apply_damage
  end

  def multiplier(%Attack{} = attack), do: multiplier(attack.attack, attack.defense)

  def multiplier("fire", "water"), do: 0
  def multiplier("fire", "life"), do: 2
  def multiplier("fire", "fire"), do: 1

  def multiplier("water", "life"), do: 0
  def multiplier("water", "fire"), do: 2
  def multiplier("water", "water"), do: 1

  def multiplier("life", "fire"), do: 0
  def multiplier("life", "water"), do: 2
  def multiplier("life", "life"), do: 1

  def log(
        %Attack{
          attack: attack,
          defense: defense,
          total_damage: total_damage,
          multiplier: multiplier
        },
        attacker,
        defender
      ) do
    Enum.reverse([
      "#{attacker} attacks with #{attack}",
      "#{defender} defends with #{defense}, it's #{effective(multiplier)}",
      "#{defender} takes #{total_damage} damage"
    ])
  end

  defp effective(0), do: "ineffective"
  defp effective(1), do: "adequate"
  defp effective(2), do: "super effetive!"

  defp apply_multiplier(%{attack: attack, defense: defense} = data) do
    %{data | multiplier: multiplier(attack, defense)}
  end

  defp apply_damage(
         %Attack{
           attack: attack,
           defense: defense,
           multiplier: multiplier,
           base_damage: base_damage
         } = data
       ) do
    %{data | total_damage: base_damage * multiplier}
  end
end
