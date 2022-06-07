defmodule SnownixWeb.AuthLiveConfirmTest do
  use SnownixWeb.LiveCase, async: true

  alias Snownix.Accounts
  import Snownix.AccountsFixtures

  setup do
    user = user_fixture()

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_confirmation_instructions(user, url)
      end)

    %{user: user, token: token}
  end

  test "redirects with invalid or empty token", %{conn: conn} do
    assert {:error,
            {:redirect,
             %{
               flash: %{"error" => "Confirm link is invalid or it has expired."},
               to: "/auth/login"
             }}} = live(conn, Routes.auth_confirm_path(conn, :confirm, "test"))
  end

  test "renders confirm account page", %{conn: conn, token: token} do
    conn = get(conn, Routes.auth_confirm_path(conn, :confirm, token))
    assert html_response(conn, 200)

    {:ok, _view, html} = live(conn, Routes.auth_confirm_path(conn, :confirm, token))
    assert html =~ "Confirm account</h1>"
    assert html =~ "You already confirmed your account?"
  end

  describe "confirmation cases" do
    test "confirm the user with valid token", %{conn: conn, user: user, token: token} do
      {:ok, view, _html} = live(conn, Routes.auth_confirm_path(conn, :confirm, token))

      form =
        view
        |> form(".auth__form form",
          user: %{
            email: user.email
          }
        )

      assert {:error, {:redirect, %{to: "/auth/login"}}} = form |> render_submit()
    end

    test "confirm the user with invalid email", %{conn: conn, token: token} do
      {:ok, view, _html} = live(conn, Routes.auth_confirm_path(conn, :confirm, token))

      form =
        view
        |> form(".auth__form form",
          user: %{email: "wrong email"}
        )

      form_view =
        form
        |> render_change()

      assert form_view =~ "must have the @ sign and no spaces"
    end
  end
end
