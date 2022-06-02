defmodule Snownix.Products.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "units" do
    field :name, :string

    belongs_to :author, Snownix.Accounts.User
    belongs_to :project, Snownix.Organizations.Project

    timestamps()
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
