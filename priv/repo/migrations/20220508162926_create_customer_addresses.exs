defmodule Snownix.Repo.Migrations.CreateCustomerAddresses do
  use Ecto.Migration

  def change do
    create table(:customer_addresses, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :title, :string

      add :country, :string
      add :city, :string
      add :fax, :string
      add :state, :string
      add :zip, :string
      add :street, :string
      add :street_2, :string
      add :phone, :string
      add :currency, :string

      add :default, :boolean, default: false

      add :customer_id, references(:customer_users, on_delete: :delete_all, type: :uuid)

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :project_id, references(:projects, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:customer_addresses, [:customer_id])

    create index(:customer_addresses, [:user_id])
    create index(:customer_addresses, [:project_id])
  end
end
