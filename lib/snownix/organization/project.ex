defmodule Snownix.Organizations.Project do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset
  import Snownix.Helpers.Model

  @primary_key {:id, :binary_id, autogenerate: true}
  @address_fields [:country, :city, :zip, :state, :street]

  schema "projects" do
    field :name, :string
    field :country, :string
    field :logo, Snownix.Uploaders.LogoUploader.Type

    field :email, :string
    field :phone, :string

    field :city, :string
    field :state, :string
    field :zip, :string
    field :street, :string

    field :currency, :string, default: "us"

    field :time_zone, :string, default: "Etc/UTC"
    field :date_format, :string, default: "%Y-%m-%d"

    field :language, :string, default: "en"
    field :fiscal_year, :string, default: "1-12"

    field :tax_per_item, :boolean, default: true
    field :discount_per_item, :boolean, default: true

    field :vat, :string

    belongs_to :user, Snownix.Accounts.User, type: :binary_id
    many_to_many :users, Snownix.Accounts.User, join_through: "users_projects"

    has_many :taxs, Snownix.Projects.Tax
    has_many :units, Snownix.Products.Unit
    has_many :customers, Snownix.Customers.User
    has_many :products, Snownix.Products.Product
    has_many :categories, Snownix.Products.Category

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :email, :country, :phone, :vat])
    |> cast_assocs()
    |> validate_length(:name, max: 100)
    |> validate_inclusion(:country, countries())
    |> validate_required([:name, :email, :country])
  end

  defp cast_assocs(changeset) do
    changeset
    |> cast_assoc(:taxs)
    |> cast_assoc(:customers)
    |> cast_assoc(:categories)
    |> cast_assoc(:products)
  end

  def address_changeset(project, attrs) do
    project
    |> cast(attrs, @address_fields)
    |> validate_length(:city, min: 0, max: 100)
    |> validate_length(:state, min: 0, max: 100)
    |> validate_length(:zip, min: 0, max: 10)
    |> validate_length(:street, min: 0, max: 500)
    |> validate_inclusion(:country, countries())
  end

  def preferences_changeset(project, attrs) do
    project
    |> changeset(attrs)
    |> cast(attrs, [
      :vat,
      :language,
      :currency,
      :fiscal_year,
      :time_zone,
      :date_format,
      :tax_per_item,
      :discount_per_item
    ])
    |> validate_length(:language, count: 2)
    |> validate_inclusion(:fiscal_year, Enum.map(fiscal_years(), & &1.id))
    |> validate_inclusion(:date_format, date_formats())
    |> validate_inclusion(:tax_per_item, booleans())
    |> validate_inclusion(:time_zone, timezones())
    |> validate_inclusion(:currency, currencies())
    |> validate_inclusion(:discount_per_item, booleans())
  end

  def owner_changeset(project, owner) do
    project
    |> change()
    |> put_assoc(:user, owner)
    |> put_assoc(:users, [owner])
  end

  def logo_changeset(project, attrs) do
    project
    |> cast_attachments(attrs, [:logo])
  end
end
