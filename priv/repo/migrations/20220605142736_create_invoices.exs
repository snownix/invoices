defmodule Snownix.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  @currency_default "USD"
  @discount_default "fixed"
  @paid_status_default "unpaid"
  @status_default "draft"

  def change do
    # Addresses
    create table(:invoice_addresses, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :city, :string
      add :country, :string
      add :currency, :string
      add :fax, :string
      add :phone, :string
      add :state, :string
      add :street, :string
      add :street_2, :string
      add :zip, :string

      add :type, :string, options: ["billing", "shipping"]

      add :address_id, references(:customer_addresses, on_delete: :nothing, type: :uuid)

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :project_id, references(:projects, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:invoice_addresses, [:user_id])
    create index(:invoice_addresses, [:address_id])
    create index(:invoice_addresses, [:project_id])

    # Invoices
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

      add :billing_address_id,
          references(:invoice_addresses, on_delete: :delete_all, type: :uuid), null: true

      add :shipping_address_id,
          references(:invoice_addresses, on_delete: :delete_all, type: :uuid), null: true

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
    create index(:invoices, [:billing_address_id])
    create index(:invoices, [:shipping_address_id])

    # Alert invoice to invoice_address
    alter table(:invoice_addresses) do
      add :invoice_id, references(:invoices, on_delete: :nothing, type: :uuid)
    end

    create index(:invoice_addresses, [:invoice_id])
  end
end
