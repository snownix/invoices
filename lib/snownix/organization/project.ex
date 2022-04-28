defmodule Snownix.Organization.Project do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @date_formats ["%Y-%m-%d", "%Y-%d-%m", "%m-%d-%Y", "%Y/%m/%d", "%Y/%d/%m", "%m/%d/%Y"]
  @fiscal_years [
    %{title: "January-February", id: "1-2"},
    %{title: "February-March", id: "2-3"},
    %{title: "March-April", id: "3-4"},
    %{title: "April-May", id: "4-5"},
    %{title: "May-June", id: "5-6"},
    %{title: "June-July", id: "6-7"},
    %{title: "July-August", id: "7-8"},
    %{title: "August-September", id: "8-9"},
    %{title: "September-October", id: "9-10"},
    %{title: "October-November", id: "10-11"},
    %{title: "November-December", id: "11-12"},
    %{title: "December-January", id: "12-1"}
  ]

  @boolean [true, false]
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

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :email, :country, :phone, :vat])
    |> validate_length(:name, max: 100)
    |> validate_inclusion(:country, countries)
    |> validate_required([:name, :email, :country])
  end

  def address_changeset(project, attrs) do
    project
    |> cast(attrs, @address_fields)
    |> validate_length(:city, min: 0, max: 100)
    |> validate_length(:state, min: 0, max: 100)
    |> validate_length(:zip, min: 0, max: 10)
    |> validate_length(:street, min: 0, max: 500)
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
    |> validate_inclusion(:fiscal_year, Enum.map(@fiscal_years, & &1.id))
    |> validate_inclusion(:date_format, @date_formats)
    |> validate_inclusion(:tax_per_item, @boolean)
    |> validate_inclusion(:time_zone, timezones())
    |> validate_inclusion(:discount_per_item, @boolean)
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

  def fiscal_years(), do: @fiscal_years
  def date_formats(), do: @date_formats

  def countries(), do: Snownix.Geo.countries()

  def timezones(), do: TzExtra.time_zone_identifiers()
end
