defmodule Snownix.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :parent_id, references(:categories, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:categories, [:parent_id])
    create index(:categories, [:project_id])
    create index(:categories, [:user_id])
  end
end
