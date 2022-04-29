defmodule Snownix.Repo.Migrations.CreateTaxs do
  use Ecto.Migration

  def change do
    create table(:taxs, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :percent, :float, default: 0.0
      add :description, :string
      add :compound_tax, :boolean, default: false, null: false

      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)
      add :author_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:taxs, [:project_id])
    create index(:taxs, [:author_id])
  end
end
