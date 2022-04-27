defmodule Snownix.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :country, :string
      add :city, :string
      add :postal, :string
      add :street, :string
      add :email, :string
      add :phone, :string
      add :vat, :string

      # logo waffle
      add :logo, :text

      add :user_id, references(:users, type: :uuid)

      timestamps()
    end
  end
end
