defmodule Snownix.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  @currency_default "USD"
  @discount_default "fixed"
  @paid_status_default "unpaid"
  @status_default "draft"

  def change do
    create table(:invoices, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :from_date, :date
      add :to_date, :date
      add :due_date, :date

      add :title, :string
      add :note, :text
      add :invoice_number, :string
      add :reference_number, :string
      add :sequence_number, :integer, default: 0
      add :status, :string, default: @status_default
      add :currency, :string, default: @currency_default

      add :discount, :integer, default: 0
      add :discount_type, :string, default: @discount_default
      add :discount_per_item, :boolean, default: false, null: false

      add :tax, :integer, default: 0
      add :tax_per_item, :boolean, default: false, null: false

      add :paid_status, :string, default: @paid_status_default

      add :viewed, :boolean, default: false
      add :sms_sent, :boolean, default: false, null: false
      add :email_sent, :boolean, default: false, null: false
      add :allow_edit, :boolean, default: false, null: false

      # add :total, :integer, default: 0, virtual: true
      # add :sub_total, :integer, default: 0, virtual: true
      # add :due_amount, :integer, default: 0, virtual: true
      # add :discount_total, :integer, default: 0, virtual: true

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :group_id, references(:groups, on_delete: :nilify_all, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)

      add :customer_id,
          references(:customer_users, on_delete: :nothing, on_replace: :update, type: :uuid)

      timestamps()
    end

    create index(:invoices, [:user_id])
    create index(:invoices, [:project_id])
    create index(:invoices, [:group_id])
    create index(:invoices, [:customer_id])
  end
end
