defmodule SnownixWeb.AuthLive.Confirm do
  use SnownixWeb, :live_view

  alias Snownix.Accounts

  def mount(%{"token" => token}, _, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, gettext("Confirm"))
      |> get_user_by_confirm_account_token(token)
    }
  end

  defp get_user_by_confirm_account_token(socket, token) do
    if user = Accounts.get_user_by_confirm_account_token(token) do
      socket
      |> assign(:user, user)
      |> assign(:token, token)
      |> assign(changeset: Accounts.user_email_changeset(%Accounts.User{}))
    else
      socket
      |> put_flash(:error, "Confirm link is invalid or it has expired.")
      |> redirect(to: Routes.auth_login_path(socket, :login))
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_email_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("update", %{"user" => user_params}, socket) do
    with %{"email" => email} <- user_params do
      case Accounts.confirm_user(socket.assigns.token, email) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Account confirmed successfully.")
           |> redirect(to: Routes.auth_login_path(socket, :login))}

        :error ->
          # If there is a current user and the account was already confirmed,
          # then odds are that the confirmation link was already visited, either
          # by some automation or by the user themselves, so we redirect without
          # a warning message.
          case socket.assigns do
            %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
              {:noreply,
               socket
               |> put_flash(:error, "Account has already been confirmed")
               |> redirect(to: Routes.auth_login_path(socket, :login))}

            %{} ->
              {:noreply,
               socket
               |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
               |> redirect(to: Routes.auth_login_path(socket, :login))}
          end
      end
    end
  end
end
