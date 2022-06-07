defmodule Snownix.Repo do
  use Ecto.Repo,
    otp_app: :snownix,
    adapter: Ecto.Adapters.Postgres

  @dialyzer {:nowarn_function, rollback: 1}
end
