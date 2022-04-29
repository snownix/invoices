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

# defmodule Snownix.Seeds do
#   import Ecto.Query, only: [from: 2]

#   alias Snownix.Repo
#   alias Snownix.Accounts.User

#   def import_demo() do
#     insert_demo_users()
#   end

#   def insert_demo_users() do
#     Repo.insert_all(User, [
#       %{
#         firstname: "Jone",
#         lastname: "Doe",
#         phone: "+212612345678",
#         email: "jone@snownix.io",
#         hashed_password: "jonepassword",
#         confirmed_at: get_naive_datetime(),
#         inserted_at: get_naive_datetime(),
#         updated_at: get_naive_datetime(1_000_000),
#         admin: true
#       }
#     ])
#   end

#   defp select_random_user() do
#     from(t in User,
#       order_by: fragment("RANDOM()"),
#       limit: 1
#     )
#     |> Repo.all()
#     |> List.first()
#   end

#   defp get_naive_datetime() do
#     NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
#   end

#   defp get_naive_datetime(time_to_add) do
#     get_naive_datetime() |> NaiveDateTime.add(time_to_add)
#   end
# end

# # dev/test branch
# if Application.get_env(:snownix, :environment) != :prod do
#   Snownix.Seeds.import_demo()
# end
