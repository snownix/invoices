defmodule Snownix.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :type, :string
      add :action, :string
      add :name, :string

      add :from, :string
      add :to, :string

      add :title, :string
      add :note, :text
      add :link, :string
      add :level, :string, default: "n"

      add :target_id, :binary_id

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:activities, [:user_id])
    create index(:activities, [:project_id])
  end
end
