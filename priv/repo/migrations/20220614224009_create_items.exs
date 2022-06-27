defmodule Snownix.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :unit_name, :string
      add :description, :text

      add :tax, :integer, default: 0
      add :total, :integer, default: 0
      add :price, :integer, default: 0
      add :discount, :integer, default: 0
      add :quantity, :integer, default: 0

      add :unit_id, references(:units, on_delete: :nilify_all, type: :uuid)
      add :invoice_id, references(:invoices, on_delete: :delete_all, type: :uuid)
      add :product_id, references(:products, on_delete: :nilify_all, type: :uuid)

      add :user_id, references(:users, on_delete: :nilify_all, type: :uuid)
      add :project_id, references(:projects, on_delete: :delete_all, type: :uuid)

      timestamps()
    end

    create index(:items, [:unit_id])
    create index(:items, [:invoice_id])
    create index(:items, [:product_id])

    create index(:items, [:user_id])
    create index(:items, [:project_id])
  end
end
