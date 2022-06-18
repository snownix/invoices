defmodule Snownix.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "invoices" do
    field :note, :string
    field :title, :string
    field :status, :string
    field :currency, :string
    field :paid_status, :string
    field :discount_type, :string
    field :invoice_number, :string
    field :reference_number, :string

    field :tax, :integer, default: 0
    field :total, :integer, default: 0
    field :discount, :integer, default: 0
    field :sub_total, :integer, default: 0
    field :due_amount, :integer, default: 0
    field :discount_val, :integer, default: 0
    field :sequence_number, :integer, default: 0

    field :to_date, :date
    field :due_date, :date
    field :from_date, :date

    field :viewed, :boolean, default: false
    field :sms_sent, :boolean, default: false
    field :email_sent, :boolean, default: false
    field :allow_edit, :boolean, default: true
    field :tax_per_item, :boolean, default: false
    field :discount_per_item, :boolean, default: false

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id
    belongs_to :customer, Snownix.Customers.User, type: :binary_id, on_replace: :nilify

    field :selected, :boolean, virtual: true, default: false
    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :title,
      :from_date,
      :to_date,
      :due_date,
      :invoice_number,
      :reference_number,
      :status,
      :paid_status,
      :tax_per_item,
      :discount_per_item,
      :note,
      :discount_type,
      :discount,
      :discount_val,
      :sub_total,
      :total,
      :tax,
      :due_amount,
      :email_sent,
      :sms_sent,
      :viewed,
      :sequence_number,
      :currency,
      :allow_edit
    ])
    |> validate_required([
      :from_date,
      :invoice_number,
      :currency
    ])
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
end
