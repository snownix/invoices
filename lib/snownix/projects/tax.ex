defmodule Snownix.Projects.Tax do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "taxs" do
    field :name, :string
    field :percent, :integer
    field :description, :string
    field :compound_tax, :boolean, default: false

    belongs_to :project, Snownix.Organizations.Project, type: :binary_id
    belongs_to :author, Snownix.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(tax, attrs) do
    tax
    |> cast(attrs, [:name, :percent, :description, :compound_tax])
    |> validate_required([:name, :percent])
    |> validate_length(:name, max: 50)
    |> validate_length(:description, max: 150)
    |> validate_number(:percent, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000)
  end

  def owner_changeset(tax, project, author) do
    tax
    |> change()
    |> put_assoc(:author, author)
    |> put_assoc(:project, project)
  end
end
