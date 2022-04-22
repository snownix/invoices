defmodule Snownix.Repo do
  use Ecto.Repo,
    otp_app: :snownix,
    adapter: Ecto.Adapters.Postgres
end
