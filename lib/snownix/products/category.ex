defmodule Snownix.Products.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "categories" do
    field :name, :string

    field :selected, :boolean, virtual: true, default: false

    belongs_to :parent, Snownix.Products.Category, type: :binary_id
    belongs_to :author, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    has_many :products, Snownix.Products.Product

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> cast_assocs()
    |> validate_required([:name])
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:products)
  end

  def owner_changeset(item, owner) do
    item
    |> change()
    |> put_assoc(:author, owner)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end
end