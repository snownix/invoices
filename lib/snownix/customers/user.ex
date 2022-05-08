defmodule Snownix.Customers.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Snownix.Helpers.Model

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

    belongs_to :author, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :contact_name, :phone, :email, :avatar, :website, :portal, :currency])
    |> validate_required([:name])
    |> validate_inclusion(:currency, currencies())
  end

  def owner_changeset(item, owner) do
    item
    |> change()
    |> put_assoc(:author, owner)
  end

  def project_changeset(item, project) do
    item
    |> change()
    |> put_assoc(:project, project)
  end
end
