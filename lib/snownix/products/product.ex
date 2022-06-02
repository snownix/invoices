defmodule Snownix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field :name, :string
    field :description, :string

    field :currency, :string

    field :price, :float
    field :tax_per_item, :float

    field :selected, :boolean, virtual: true, default: false

    belongs_to :category, Snownix.Products.Category, type: :binary_id
    belongs_to :unit, Snownix.Products.Unit, type: :binary_id
    belongs_to :author, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :tax_per_item, :currency])
    |> validate_required([:name, :price])
  end
end
