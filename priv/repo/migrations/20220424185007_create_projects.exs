defmodule Snownix.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :email, :string
      add :phone, :string

      add :country, :string
      add :city, :string
      add :zip, :string
      add :state, :string
      add :street, :string

      add :vat, :string

      add :currency, :string, default: "us"

      add :time_zone, :string, default: "Etc/UTC"
      add :date_format, :string, default: "%Y-%m-%d"

      add :language, :string, default: "en"
      add :fiscal_year, :string, default: "1-12"

      add :tax_per_item, :boolean, default: true
      add :discount_per_item, :boolean, default: true

      # logo waffle
      add :logo, :text

      add :user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
