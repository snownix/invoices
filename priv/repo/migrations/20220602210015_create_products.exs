defmodule Snownix.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :description, :text
      add :price, :integer
      add :tax_per_item, :integer
      add :currency, :string

      add :category_id, references(:categories, on_delete: :nothing, type: :uuid)
      add :unit_id, references(:units, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)
      add :author_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:products, [:category_id])
    create index(:products, [:unit_id])
    create index(:products, [:project_id])
    create index(:products, [:author_id])
  end
end
