defmodule Snownix.Invoices.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "groups" do
    field :name, :string
    field :identifier_format, :string

    field :left_pad, :integer, default: 6
    field :next_id, :integer, default: 1

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :next_id, :identifier_format, :left_pad])
    |> validate_required([:name, :next_id, :identifier_format, :left_pad])
  end

  def owner_changeset(item, project, user) do
    item
    |> change()
    |> project_changeset(project)
    |> user_changeset(user)
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
end
