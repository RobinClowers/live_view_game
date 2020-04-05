defmodule Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}

  schema "player" do
    field(:name, :string)
  end

  def new(params \\ %{}) do
    %Player{}
    |> cast(params, [:id, :name])
    |> validate_required([:id, :name])
  end
end
