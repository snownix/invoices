defmodule Snownix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "products" do
    field :name, :string
    field :description, :string

    field :currency, :string

    field :price, :integer, default: 0
    field :price_float, :float, virtual: true, default: 0.0, scale: 2
    field :tax_per_item, :integer, default: 0
    field :tax_per_item_float, :float, default: 0.0, virtual: true

    field :selected, :boolean, virtual: true, default: false

    belongs_to :category, Snownix.Products.Category, type: :binary_id
    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id
    belongs_to :unit, Snownix.Products.Unit, type: :binary_id

    timestamps()
  end

  @fields [
    :name,
    :description,
    :price,
    :price_float,
    :tax_per_item,
    :tax_per_item_float,
    :currency,
    :unit_id,
    :category_id
  ]

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required([:name, :price, :currency, :tax_per_item])
    |> cast_float_to_int(price_float: :price, tax_per_item_float: :tax_per_item)
  end

  def change_project(changeset, project) do
    put_assoc(changeset, :project, project)
  end

  def change_category(changeset, %{id: id}) do
    put_change(changeset, :category_id, id)
  end

  def change_category(changeset, _), do: changeset

  def change_user(changeset, user) do
    put_assoc(changeset, :user, user)
  end

  def owner_changeset(item, owner) do
    item
    |> change()
    |> put_assoc(:user, owner)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end
end
