defmodule SnownixWeb.AuthLive.ResetPassword do
  use SnownixWeb, :live_view

  alias Snownix.Accounts

  def mount(%{"token" => token}, _, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, gettext("Reset Password"))
      |> get_user_by_reset_password_token(token)
    }
  end

  defp get_user_by_reset_password_token(socket, token) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      socket
      |> assign(:user, user)
      |> assign(:token, token)
      |> assign(:changeset, Accounts.user_password_changeset(%Accounts.User{}))
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: Routes.auth_login_path(socket, :login))
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_password_with_email_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("update", %{"user" => user_params}, socket) do
    with %{"email" => email} <- user_params do
      if socket.assigns.user.email === email do
        case Accounts.reset_user_password(socket.assigns.user, user_params) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Password reset successfully.")
             |> redirect(to: Routes.auth_login_path(socket, :login))}

          {:error, changeset} ->
            {:noreply,
             socket
             |> assign(changeset: changeset)}
        end
      else
        {:noreply, socket |> put_flash(:error, gettext("Wrong information"))}
      end
    end
  end
end
