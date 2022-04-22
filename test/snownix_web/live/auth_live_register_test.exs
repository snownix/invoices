defmodule SnownixWeb.AuthLiveRegisterTest do
  use SnownixWeb.LiveCase, async: true

  import Snownix.AccountsFixtures

  setup do
    %{
      user: user_fixture(),
      user_unique: %{
        firstname: unique_name(),
        lastname: unique_name(),
        email: unique_user_email(),
        password: valid_user_password()
      }
    }
  end

  test "renders sign up page", %{conn: conn} do
    conn = get(conn, Routes.auth_register_path(conn, :register))
    assert html_response(conn, 200)

    {:ok, _view, html} = live(conn, Routes.auth_register_path(conn, :register))
    assert html =~ "Sign up</h1>"
    assert html =~ "Already have an account?"
  end

  test "redirects if already logged in", %{conn: conn, user: user} do
    assert {:error, {:redirect, %{to: "/"}}} =
             live(conn = conn |> log_in_user(user), Routes.auth_register_path(conn, :register))
  end

  test "register the user", %{conn: conn, user_unique: user} do
    {:ok, view, _html} = live(conn, Routes.auth_register_path(conn, :register))
    form = view |> form(".auth__form form", user: user)

    assert {:error, {:redirect, %{to: "/auth/login"}}} = form |> render_submit()
  end

  test "render errors for invalid data", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.auth_register_path(conn, :register))

    form =
      view
      |> form(".auth__form form",
        user: %{
          email: "wrong email",
          firstname: "48946 firstname @ ^$",
          lastname: "456 lastname @ ^$",
          password: nil
        }
      )

    form_view =
      form
      |> render_submit()

    assert form_view =~ "firstname must be alphanumeric"
    assert form_view =~ "lastname must be alphanumeric"
    assert form_view =~ "must have the @ sign and no spaces"
    assert form_view =~ "can"
    assert form_view =~ "t be blank"
  end
end
