defmodule Snownix.Products.Unit do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "units" do
    field :name, :string

    field :selected, :boolean, virtual: true, default: false

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def owner_changeset(unit, project, user) do
    unit
    |> change()
    |> put_assoc(:user, user)
    |> put_assoc(:project, project)
  end
end
