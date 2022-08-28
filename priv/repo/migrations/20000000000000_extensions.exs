defmodule ShopTest.Repo.Migrations.Extensions do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext"
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch"
  end

  def down do
    execute "DROP EXTENSION citext"
    execute "DROP EXTENSION fuzzystrmatch"
    execute "DROP EXTENSION pg_trgm"
  end
end
