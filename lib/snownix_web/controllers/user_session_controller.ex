defmodule SnownixWeb.UserSessionController do
  use SnownixWeb, :controller

  alias Snownix.Accounts
  alias SnownixWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      conn
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      |> put_flash(:error, "Invalid email or password")
      |> redirect(to: Routes.auth_login_path(conn, :login))
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
