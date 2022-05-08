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
    |> Enum.each(
      &(Project.changeset(%Project{}, &1)
        |> Project.owner_changeset(&1.user)
        |> Repo.insert!())
    )
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
        customers: many_rands(&generate_rand_customer/0, 200, 100),
        user: user
      }
    end
  end

  defp generate_rand_tax() do
    %{name: Faker.Pokemon.name(), percent: Float.round(:rand.uniform(100) * 0.5)}
  end

  defp generate_rand_customer() do
    %{
      name: Faker.Company.En.name(),
      contact_name: Faker.Person.name(),
      phone: Faker.Phone.EnUs.phone(),
      email: Faker.Internet.email()
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
