defmodule Snownix.Invoices.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Changeset

  alias Snownix.Invoices.Item

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}

  @discount_default "fixed"

  schema "items" do
    field :temp_id, :binary_id, virtual: true

    field :name, :string
    field :unit_name, :string
    field :description, :string

    field :price, :integer, default: 0
    field :discount, :integer, default: 0
    field :discount_type, :string, default: @discount_default
    field :quantity, :integer, default: 0

    field :taxs, {:array, :map}, default: []

    belongs_to :unit, Snownix.Products.Unit, type: :binary_id, on_replace: :nilify
    belongs_to :product, Snownix.Products.Product, type: :binary_id, on_replace: :nilify
    belongs_to :invoice, Snownix.Invoices.Invoice, type: :binary_id, on_replace: :nilify

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()

    field :total, :integer, default: 0, virtual: true
    field :sub_total, :integer, default: 0, virtual: true
    field :price_float, :float, default: 0.0, scale: 2, virtual: true
    field :discount_float, :float, default: 0.0, scale: 2, virtual: true

    field :discount_total, :integer, default: 0, virtual: true
    field :discount_per_item, :boolean, default: false, virtual: true

    field :tax_total, :integer, default: 0, virtual: true
    field :tax_per_item, :boolean, default: false, virtual: true

    field :selected, :boolean, default: false, virtual: true
  end

  @doc false
  def changeset(item, attrs \\ %{}, opts \\ []) do
    item
    |> cast(attrs, [
      :temp_id,
      :name,
      :description,
      :price_float,
      :discount_float,
      :discount_type,
      :quantity,
      :unit_name,
      :discount_per_item,
      :tax_per_item,
      :taxs
    ])
    |> cast_float_to_int(:price_float, :price)
    |> cast_float_to_int(:discount_float, :discount)
    |> validate_required([
      :name,
      :price,
      :quantity
    ])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_number(:discount, greater_than_or_equal_to: 0)
    |> update_calcs(opts)
  end

  def update_calcs(%Ecto.Changeset{} = changeset, opts) do
    tax_per_item = Keyword.get(opts, :tax_per_item, get_field(changeset, :tax_per_item, false))

    discount_per_item =
      Keyword.get(opts, :discount_per_item, get_field(changeset, :discount_per_item, false))

    price = get_field(changeset, :price, 0)
    quantity = get_field(changeset, :quantity, 0)
    discount = get_field(changeset, :discount, 0)
    discount_type = get_field(changeset, :discount_type, @discount_default)

    sub_total = quantity * price
    total = apply_discount(discount_type, sub_total, (discount_per_item && discount) || 0)

    discount_total = calc_discount(discount_type, sub_total, (discount_per_item && discount) || 0)

    changeset
    |> put_change(:total, total)
    |> put_change(:sub_total, sub_total)
    |> put_change(:discount_total, discount_total)
  end

  def update_calcs(%Item{} = item, opts) do
    %{
      price: price,
      quantity: quantity,
      discount: discount,
      discount_type: discount_type,
      discount_per_item: discount_per_item,
      price_float: price_float,
      discount_float: discount_float
    } = item

    discount_per_item = Keyword.get(opts, :discount_per_item, discount_per_item)

    sub_total = quantity * price
    total = apply_discount(discount_type, sub_total, (discount_per_item && discount) || 0)

    discount_total = calc_discount(discount_type, sub_total, (discount_per_item && discount) || 0)

    item
    |> cast_int_to_float(:price, :price_float)
    |> cast_int_to_float(:discount, :discount_float)
    |> Map.put(:total, total)
    |> Map.put(:sub_total, sub_total)
    |> Map.put(:discount_total, discount_total)
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
