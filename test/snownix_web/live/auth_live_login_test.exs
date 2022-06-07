defmodule SnownixWeb.AuthLiveLoginTest do
  use SnownixWeb.LiveCase, async: true

  import Snownix.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  test "renders log in page", %{conn: conn} do
    conn = get(conn, Routes.auth_login_path(conn, :login))
    assert html_response(conn, 200)

    {:ok, _view, html} = live(conn, Routes.auth_login_path(conn, :login))
    assert html =~ "Sign in</h1>"
    assert html =~ "Forgot password?"
  end

  test "redirects if already logged in", %{conn: conn, user: user} do
    assert {:error, {:redirect, %{to: "/"}}} =
             live(conn = conn |> log_in_user(user), Routes.auth_login_path(conn, :login))
  end

  test "logs the user in", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.auth_login_path(conn, :login))

    form =
      view
      |> form(".auth__form form", user: %{email: user.email, password: valid_user_password()})

    assert form
           |> render_submit() =~ "Welcome back #{user.firstname}!"

    conn = follow_trigger_action(form, conn)
    assert conn.method == "POST"

    assert conn.params == %{
             "user" => %{"email" => user.email, "password" => valid_user_password()}
           }
  end

  test "receive error message with invalid credentials", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, Routes.auth_login_path(conn, :login))

    form =
      view
      |> form(".auth__form form", user: %{email: user.email, password: wrong_user_password()})

    assert form
           |> render_submit() =~ "Invalid email or password"
  end
end
