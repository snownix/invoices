defmodule Snownix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field :name, :string
    field :description, :string

    field :currency, :string

    field :price, :integer, default: 0
    field :tax_per_item, :boolean, default: false

    field :selected, :boolean, virtual: true, default: false

    belongs_to :category, Snownix.Products.Category, type: :binary_id
    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id
    belongs_to :unit, Snownix.Products.Unit, type: :binary_id

    timestamps()
  end

  @fields [:name, :description, :price, :tax_per_item, :currency, :unit_id, :category_id]

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required([:name, :price, :currency])
  end

  def owner_changeset(item, project, owner) do
    item
    |> change()
    |> put_assoc(:user, owner)
    |> put_assoc(:project, project)
  end
end
