defmodule Snownix.Repo.Migrations.CreateCustomerUsers do
  use Ecto.Migration

  def change do
    create table(:customer_users, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :contact_name, :string
      add :phone, :string
      add :email, :string
      add :avatar, :string
      add :website, :string
      add :portal, :boolean, default: false, null: false
      add :currency, :string

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:customer_users, [:project_id])
    create index(:customer_users, [:user_id])
  end
end
