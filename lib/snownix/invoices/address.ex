defmodule Snownix.Invoices.Address do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  import Snownix.Helpers.Model
  alias Snownix.Invoices.Address

  @primary_key {:id, :binary_id, autogenerate: true}
  @address_fields [:country, :city, :zip, :state, :street, :street_2]
  @fields [:country, :city, :state, :zip, :street, :street_2, :fax, :phone]
  @valid [:street, :city, :state, :zip, :street_2, :fax, :phone]
  @types ["billing", "shipping"]

  schema "invoice_addresses" do
    field :city, :string
    field :country, :string
    field :fax, :string
    field :phone, :string
    field :state, :string
    field :street, :string
    field :street_2, :string
    field :zip, :string

    field :type, :string, options: ["billing", "shipping"]

    belongs_to :address, Snownix.Customers.Address, type: :binary_id
    belongs_to :invoice, Snownix.Invoices.Invoice, type: :binary_id

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(address, attrs, ops \\ []) do
    address
    |> cast(attrs, @fields, empty_values: [""])
    |> cast_assocs()
    |> put_type(ops)
    |> validate_required([:country, :city, :street, :type])
    |> address_changeset(attrs)
    |> validate_length(:fax, min: 0, max: 15)
    |> validate_length(:phone, min: 0, max: 15)
    |> validate_inclusion(:type, @types)
  end

  defp put_type(changeset, opts) do
    changeset |> put_change(:type, Keyword.get(opts, :type, nil))
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:user)
    |> cast_assoc(:project)
    |> cast_assoc(:address)
    |> cast_assoc(:invoice)
  end

  def address_changeset(item, attrs) do
    item
    |> cast(attrs, @address_fields)
    |> validate_length(:city, min: 0, max: 100)
    |> validate_length(:state, min: 0, max: 100)
    |> validate_length(:zip, min: 0, max: 20)
    |> validate_length(:street, min: 0, max: 500)
    |> validate_length(:street_2, min: 0, max: 500)
    |> validate_inclusion(:country, countries())
  end

  def invoice_changeset(item, invoice) do
    item
    |> change()
    |> put_assoc(:invoice, invoice)
  end

  def user_changeset(item, user) do
    item
    |> change()
    |> put_assoc(:user, user)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end

  def is_valid(nil), do: false

  def is_valid(invoice) do
    changeset = change(invoice)
    !is_nil(Enum.find(@valid, &get_field(changeset, &1)))
  end
end
