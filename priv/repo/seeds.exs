# # Script for populating the database. You can run it as:
# #
# #     mix run priv/repo/seeds.exs
# #
# # Inside the script, you can read and write to any of your
# # repositories directly:
# #
# #     Snownix.Repo.insert!(%Snownix.SomeSchema{})
# #
# # We recommend using the bang functions (`insert!`, `update!`
# # and so on) as they will fail if something goes wrong.

defmodule Snownix.Seeds do
  import Ecto.Query, only: [from: 2]

  alias Snownix.Repo
  alias Snownix.Accounts.User
  alias Snownix.Customers.Address
  alias Snownix.Organizations.Project

  def import_demo() do
    insert_demo_users()
    insert_demo_projects()
  end

  def insert_demo_users() do
    Repo.insert_all(User, [
      %{
        firstname: "Jone",
        lastname: "Doe",
        phone: "+212612345678",
        email: "jone@snownix.io",
        hashed_password: Bcrypt.hash_pwd_salt("jone@snownix.io"),
        confirmed_at: get_naive_datetime(),
        inserted_at: get_naive_datetime(),
        updated_at: get_naive_datetime(1_000_000),
        admin: true
      }
    ])
  end

  def insert_demo_projects() do
    many_rands(&generate_rand_project/0, 8, 2)
    |> Enum.each(fn p ->
      project =
        Project.changeset(%Project{}, p)
        |> Project.owner_changeset(p.user)
        |> Repo.insert!(timeout: :infinity)

      project.customers
      |> Repo.preload(:addresses)
      |> Enum.each(fn c ->
        c.addresses
        |> Repo.preload(:project)
        |> Enum.each(fn a ->
          Address.project_changeset(a, project)
          |> Repo.update!()
        end)
      end)
    end)
  end

  defp many_rands(call, max \\ 5, min \\ 1) do
    for _i <- min..:rand.uniform(max), do: call.()
  end

  defp generate_rand_project() do
    with user <- select_random_user() do
      %{
        name: Faker.Company.En.name(),
        country: Faker.Address.country_code(),
        phone: Faker.Phone.EnUs.phone(),
        email: Faker.Internet.email(),
        city: Faker.Address.city(),
        state: Faker.Address.state(),
        zip: Faker.Address.zip(),
        street: Faker.Address.street_address(),
        currency: Faker.Currency.code(),
        time_zone: "Etc/UTC",
        taxs: many_rands(&generate_rand_tax/0),
        customers: many_rands(&generate_rand_customer/0, 100, 20),
        categories: many_rands(&generate_rand_category/0, 6, 4),
        products: many_rands(&generate_rand_products/0, 100, 10),
        user: user
      }
    end
  end

  defp generate_rand_tax() do
    %{
      name: Faker.Pokemon.name(),
      percent: Enum.random(1..50) * 100
    }
  end

  defp generate_rand_customer() do
    %{
      name: Faker.Company.En.name(),
      contact_name: Faker.Person.name(),
      phone: Faker.Phone.EnUs.phone(),
      email: Faker.Internet.email(),
      addresses: many_rands(&generate_rand_address/0, 5, 1)
    }
  end

  defp generate_rand_category() do
    %{
      name: Faker.Vehicle.make()
    }
  end

  defp generate_rand_products() do
    %{
      name: Faker.Vehicle.make_and_model(),
      description: Faker.Vehicle.standard_specs() |> Enum.join(", "),
      price: round(Faker.Commerce.price() * 10000),
      currency: Faker.Currency.code(),
      tax_per_item: Enum.random(1..50) * 100
    }
  end

  defp generate_rand_address() do
    %{
      country: Faker.Address.country_code(),
      phone: Faker.Phone.EnUs.phone(),
      email: Faker.Internet.email(),
      city: Faker.Address.city(),
      state: Faker.Address.state(),
      zip: Faker.Address.zip(),
      street: Faker.Address.street_address(),
      street_2: Faker.Address.street_address()
    }
  end

  defp select_random_user() do
    from(t in User,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.all()
    |> List.first()
  end

  defp get_naive_datetime() do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  defp get_naive_datetime(time_to_add) do
    get_naive_datetime() |> NaiveDateTime.add(time_to_add)
  end
end

# dev/test branch
if Application.get_env(:snownix, :environment) != :prod do
  Snownix.Seeds.import_demo()
end
