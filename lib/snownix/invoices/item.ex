defmodule Snownix.Invoices.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Changeset

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "items" do
    field :temp_id, :binary_id, virtual: true

    field :name, :string
    field :unit_name, :string
    field :description, :string

    field :tax, :integer, default: 0
    field :price, :integer, default: 0
    field :price_float, :float, virtual: true, default: 0.0, scale: 2
    field :total, :integer, default: 0
    field :discount, :integer, default: 0
    field :quantity, :integer, default: 0

    belongs_to :unit, Snownix.Products.Unit, type: :binary_id, on_replace: :nilify
    belongs_to :product, Snownix.Products.Product, type: :binary_id, on_replace: :nilify
    belongs_to :invoice, Snownix.Invoices.Invoice, type: :binary_id, on_replace: :nilify

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    field :selected, :boolean, virtual: true, default: false
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :description,
      :price_float,
      :quantity,
      :unit_name,
      :discount,
      :tax,
      :total
    ])
    |> cast_float_to_int(:price_float, :price)
    |> validate_required([
      :name,
      :price,
      :quantity,
      :total
    ])
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:tax, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0)
    |> maybe_update_total()
  end

  defp maybe_update_total(changeset) do
    changeset
    |> put_change(:total, get_field(changeset, :quantity, 0) * get_field(changeset, :price, 0))
  end

  def unit_changeset(item, unit) do
    item
    |> change()
    |> put_assoc(:unit, unit)
  end

  def product_changeset(item, product) do
    item
    |> change()
    |> put_assoc(:product, product)
  end

  def invoice_changeset(item, invoice) do
    item
    |> change()
    |> put_assoc(:invoice, invoice)
  end

  def owner_changeset(item, user) do
    item
    |> change()
    |> put_assoc(:user, user)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end
end
