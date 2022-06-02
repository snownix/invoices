defmodule Snownix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field :currency, :string
    field :description, :string
    field :name, :string
    field :price, :float
    field :tax_per_item, :float

    belongs_to :category, Snownix.Products.Category
    belongs_to :unit, Snownix.Products.Unit
    belongs_to :author, Snownix.Accounts.User
    belongs_to :project, Snownix.Organizations.Project

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :tax_per_item, :currency])
    |> validate_required([:name, :description, :price, :tax_per_item, :currency])
  end
end
