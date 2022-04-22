defmodule Snownix.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :firstname, :citext
      add :lastname, :citext
      add :email, :citext, null: false
      add :hashed_password, :string, null: false

      add :admin, :bool, default: false

      add :phone, :string, size: 20

      # url
      add :avatar, :text

      # active, inactive, suspend, banned
      add :status, :string, size: 10

      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
