defmodule Snownix.Products.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "categories" do
    field :name, :string

    belongs_to :parent, Snownix.Products.Category
    belongs_to :author, Snownix.Accounts.User
    belongs_to :project, Snownix.Organizations.Project

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
