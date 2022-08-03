defmodule Snownix.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :identifier_format, :string
      add :next_id, :integer, default: 0
      add :left_pad, :integer, default: 0

      add :user_id, references(:users, on_delete: :nilify_all, type: :uuid)
      add :project_id, references(:projects, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:groups, [:user_id])
    create index(:groups, [:project_id])
  end
end
