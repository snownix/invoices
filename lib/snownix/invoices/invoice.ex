defmodule Snownix.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "invoices" do
    field :note, :string
    field :status, :string
    field :currency, :string
    field :paid_status, :string
    field :discount_type, :string
    field :invoice_number, :string
    field :reference_number, :string

    field :tax, :integer
    field :total, :integer
    field :viewed, :integer
    field :discount, :integer
    field :sub_total, :integer
    field :due_amount, :integer
    field :discount_val, :integer
    field :sequence_number, :integer

    field :to_date, :naive_datetime
    field :due_date, :naive_datetime
    field :from_date, :naive_datetime

    field :sent_sms, :boolean, default: false
    field :sent_email, :boolean, default: false
    field :allow_edit, :boolean, default: false
    field :tax_per_item, :boolean, default: false
    field :discount_per_item, :boolean, default: false

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :customer, Snownix.Customers.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
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
      :sent_email,
      :sent_sms,
      :viewed,
      :sequence_number,
      :currency,
      :allow_edit
    ])
    |> validate_required([
      :from_date,
      :to_date,
      :due_date,
      :invoice_number,
      :reference_number,
      :sequence_number,
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
