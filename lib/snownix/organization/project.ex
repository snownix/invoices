defmodule Snownix.Organization.Project do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "projects" do
    field :name, :string
    field :country, :string
    field :logo, Snownix.Uploaders.LogoUploader.Type

    field :email, :string
    field :phone, :string

    field :city, :string
    field :postal, :string
    field :street, :string

    field :vat, :string

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    many_to_many :users, Snownix.Accounts.User, join_through: "users_projects"

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :country, :city, :postal, :street, :email, :phone, :vat])
    |> validate_length(:name, max: 100)
    |> validate_required([:name, :email, :country])
  end

  def owner_changeset(project, owner) do
    project
    |> change()
    |> put_assoc(:user, owner)
    |> put_assoc(:users, [owner])
  end

  def logo_changeset(project, attrs) do
    project
    |> cast_attachments(attrs, [:logo])
  end
end
