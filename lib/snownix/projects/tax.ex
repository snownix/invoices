defmodule Snownix.Projects.Tax do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Changeset
  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "taxs" do
    field :name, :string
    field :percent, :integer, default: 0
    field :percent_float, :float, default: 0.0, virtual: true
    field :description, :string
    field :compound_tax, :boolean, default: false

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tax, attrs) do
    tax
    |> cast(attrs, [:name, :percent, :percent_float, :description, :compound_tax])
    |> cast_float_to_int(:percent_float, :percent)
    |> validate_required([:name, :percent])
    |> validate_length(:name, max: 50)
    |> validate_length(:description, max: 150)
    |> validate_number(:percent, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000)
    |> validate_number(:percent_float, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  def owner_changeset(tax, project, user) do
    tax
    |> change()
    |> put_assoc(:user, user)
    |> put_assoc(:project, project)
  end
end
