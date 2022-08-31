defmodule Snownix.Customers.Address do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  import Snownix.Helpers.Model

  @primary_key {:id, :binary_id, autogenerate: true}
  @address_fields [:country, :city, :zip, :state, :street, :street_2]
  @fields [:currency, :country, :title, :city, :state, :zip, :street, :street_2, :fax, :phone]

  schema "customer_addresses" do
    field :title, :string

    field :city, :string
    field :country, :string
    field :currency, :string
    field :fax, :string
    field :phone, :string
    field :state, :string
    field :street, :string
    field :street_2, :string
    field :zip, :string

    field :billing_default, :boolean, default: false
    field :shipping_default, :boolean, default: false

    belongs_to :customer, Snownix.Customers.User, type: :binary_id

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, @fields)
    |> cast_assocs()
    |> validate_required([:country, :city, :state, :zip, :street])
    |> address_changeset(attrs)
    |> validate_length(:fax, min: 0, max: 15)
    |> validate_length(:phone, min: 0, max: 15)
    |> validate_length(:title, min: 0, max: 200)
    |> validate_inclusion(:currency, currencies())
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:user)
    |> cast_assoc(:project)
    |> cast_assoc(:customer)
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

  def customer_changeset(item, customer) do
    item
    |> change()
    |> put_assoc(:customer, customer)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end
end
