defmodule Snownix.Repo.Migrations.CreateUsersProjects do
  use Ecto.Migration

  def change do
    create table(:users_projects) do
      add :project_id, references(:projects, type: :uuid)
      add :user_id, references(:users, type: :uuid)
    end

    create unique_index(:users_projects, [:project_id, :user_id])
  end
end
