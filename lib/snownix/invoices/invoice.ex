defmodule Snownix.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Changeset

  alias Snownix.Invoices.Item
  alias Snownix.Invoices.Invoice

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}

  @discount_default "fixed"

  schema "invoices" do
    field :note, :string
    field :title, :string
    field :currency, :string

    field :status, :string
    field :paid_status, :string

    field :invoice_number, :string
    field :reference_number, :string
    field :sequence_number, :integer, default: 0

    field :discount, :integer, default: 0

    # Saved to sort it easly in data tables

    field :discount_type, :string, default: @discount_default
    field :discount_per_item, :boolean, default: false

    field :tax, :integer, default: 0
    field :tax_per_item, :boolean, default: false

    field :to_date, :date
    field :due_date, :date
    field :from_date, :date

    field :viewed, :boolean, default: false
    field :sms_sent, :boolean, default: false
    field :email_sent, :boolean, default: false
    field :allow_edit, :boolean, default: true

    field :total, :integer, default: 0, virtual: true
    field :due_amount, :integer, default: 0, virtual: true
    field :sub_total, :integer, default: 0, virtual: true
    field :tax_total, :integer, default: 0, virtual: true
    field :discount_total, :integer, default: 0, virtual: true

    field :discount_float, :float, default: 0.0, virtual: true, scale: 2

    has_many :items, Snownix.Invoices.Item, on_replace: :delete

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id
    belongs_to :group, Snownix.Organizations.Group, type: :binary_id
    belongs_to :customer, Snownix.Customers.User, type: :binary_id, on_replace: :nilify

    belongs_to :billing_address, Snownix.Invoices.Address, type: :binary_id
    belongs_to :shipping_address, Snownix.Invoices.Address, type: :binary_id

    field :parent_id, :binary_id, virtual: true, default: ""
    field :selected, :boolean, virtual: true, default: false

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :title,
      :note,
      :from_date,
      :to_date,
      :due_date,
      :invoice_number,
      :reference_number,
      :status,
      :paid_status,
      :tax_per_item,
      :discount_type,
      :discount_float,
      :discount_per_item,
      :tax,
      :due_amount,
      :sub_total,
      :sms_sent,
      :viewed,
      :sequence_number,
      :currency,
      :allow_edit
    ])
    |> cast_float_to_int([
      {:discount_float, :discount}
    ])
    |> validate_required([
      :currency,
      :from_date,
      :invoice_number
    ])
    |> cast_assocs()
    |> cast_items()
    |> update_calcs()
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:customer)
    |> cast_assoc(:billing_address)
    |> cast_assoc(:shipping_address)
  end

  def cast_items(changeset) do
    discount_per_item = get_field(changeset, :discount_per_item)

    changeset
    |> cast_assoc(:items, with: {Item, :changeset, [[discount_per_item: discount_per_item]]})
  end

  def update_calcs(%Invoice{} = invoice) do
    %{
      items: items,
      discount_per_item: discount_per_item,
      discount: discount,
      discount_type: discount_type
    } = invoice

    items = items |> Enum.map(&Item.update_calcs(&1, discount_per_item: discount_per_item))

    {total, sub_total, discount_total, tax_total} =
      Enum.reduce(items, {0, 0, 0, 0}, fn item, {total, sub_total, discount_total, tax_total} ->
        total = total + item.total
        sub_total = sub_total + item.sub_total
        discount_total = discount_total + item.discount_total
        tax_total = tax_total + item.tax_total

        {
          total,
          sub_total,
          discount_total,
          tax_total
        }
      end)

    discount_total = discount_total + calc_discount(discount_type, total, discount)
    total = apply_discount(discount_type, total, discount)

    invoice
    |> Map.put(:items, items)
    |> Map.put(:total, total)
    |> Map.put(:sub_total, sub_total)
    |> Map.put(:tax_total, tax_total)
    |> Map.put(:discount_total, discount_total)
  end

  def update_calcs(%Ecto.Changeset{} = changeset) do
    items = get_field(changeset, :items, [])

    {total, sub_total, discount_total, tax_total} =
      Enum.reduce(items, {0, 0, 0, 0}, fn item, {total, sub_total, discount_total, tax_total} ->
        total = total + item.total
        sub_total = sub_total + item.sub_total
        discount_total = discount_total + item.discount_total
        tax_total = tax_total + item.tax_total

        {
          total,
          sub_total,
          discount_total,
          tax_total
        }
      end)

    discount = get_field(changeset, :discount, 0)
    discount_type = get_field(changeset, :discount_type, "fixed")

    discount_total = discount_total + calc_discount(discount_type, total, discount)

    total = apply_discount(discount_type, total, discount)

    changeset
    |> put_change(:total, total)
    |> put_change(:sub_total, sub_total)
    |> put_change(:tax_total, tax_total)
    |> put_change(:discount_total, discount_total)
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

  def customer_changeset(item, customer) do
    item
    |> change()
    |> put_assoc(:customer, customer)
  end

  def group_changeset(item, group) do
    item
    |> change()
    |> put_assoc(:group, group)
  end
end
