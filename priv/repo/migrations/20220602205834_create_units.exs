defmodule Snownix.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:units, [:project_id])
    create index(:units, [:user_id])
  end
end
