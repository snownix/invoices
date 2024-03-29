defmodule Snownix.Customers.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Snownix.Helpers.Model

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "customer_users" do
    field :avatar, :string
    field :contact_name, :string
    field :currency, :string
    field :email, :string
    field :name, :string
    field :phone, :string
    field :portal, :boolean, default: false
    field :website, :string
    field :selected, :boolean, virtual: true, default: false

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    has_many :addresses, Snownix.Customers.Address,
      foreign_key: :customer_id,
      on_delete: :delete_all

    has_many :invoices, Snownix.Invoices.Invoice,
      foreign_key: :customer_id,
      on_delete: :nilify_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :contact_name, :phone, :email, :avatar, :website, :portal, :currency])
    |> cast_assocs()
    |> validate_required([:name])
    |> validate_inclusion(:currency, currencies())
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:addresses)
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
