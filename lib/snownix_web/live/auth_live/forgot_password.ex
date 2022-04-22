defmodule SnownixWeb.AuthLive.ForgotPassword do
  use SnownixWeb, :live_view

  alias Snownix.Accounts

  def mount(_, _, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, gettext("Forgot Password"))
      |> assign(
        :changeset,
        Accounts.user_email_changeset(%Accounts.User{})
      )
    }
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_email_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("update", %{"user" => user_params}, socket) do
    %{"email" => email} = user_params

    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &Routes.auth_reset_password_url(socket, :reset, &1)
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext(
         "If your email is in our system, you will receive instructions to reset your password shortly."
       )
     )
     |> redirect(to: Routes.auth_login_path(socket, :login))}
  end
end
