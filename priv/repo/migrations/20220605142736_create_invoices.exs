defmodule Snownix.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :to_date, :date
      add :from_date, :date
      add :due_date, :date

      add :note, :text
      add :title, :string
      add :status, :string
      add :currency, :string
      add :paid_status, :string
      add :discount_type, :string
      add :invoice_number, :string
      add :reference_number, :string

      add :tax, :integer, default: 0
      add :total, :integer, default: 0
      add :discount, :integer, default: 0
      add :sub_total, :integer, default: 0
      add :due_amount, :integer, default: 0
      add :discount_val, :integer, default: 0
      add :sequence_number, :integer, default: 0

      add :viewed, :boolean, default: false
      add :sms_sent, :boolean, default: false, null: false
      add :allow_edit, :boolean, default: false, null: false
      add :email_sent, :boolean, default: false, null: false
      add :tax_per_item, :boolean, default: false, null: false
      add :discount_per_item, :boolean, default: false, null: false

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)

      add :customer_id,
          references(:customer_users, on_delete: :nothing, on_replace: :update, type: :uuid)

      timestamps()
    end

    create index(:invoices, [:user_id])
    create index(:invoices, [:project_id])
    create index(:invoices, [:customer_id])
  end
end
