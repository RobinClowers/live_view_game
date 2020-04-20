defmodule LiveGame.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveGame.Player

  @primary_key {:id, :string, []}

  schema "player" do
    field(:name, :string)
    field(:hp, :integer, default: 20)
    field(:in_battle, :boolean, default: false)
    field(:character, :string)
  end

  def new(params \\ %{}) do
    %Player{}
    |> cast(params, [:id, :name, :character])
    |> validate_required([:id, :name, :character])
  end
end
