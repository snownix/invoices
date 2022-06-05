defmodule Snownix.Projects.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "activities" do
    field :from, :string
    field :level, :string
    field :link, :string
    field :note, :string
    field :target_id, Ecto.UUID
    field :title, :string
    field :to, :string
    field :type, :string
    field :action, :string
    field :name, :string

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    belongs_to :project, Snownix.Organizations.Project, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:type, :target_id, :name, :from, :action, :to, :title, :note, :level, :link])
    |> validate_required([:type, :title])
  end

  def owner_changeset(activity, project, user) do
    activity
    |> change()
    |> put_assoc(:project, project)
    |> put_assoc(:user, user)
  end
end
