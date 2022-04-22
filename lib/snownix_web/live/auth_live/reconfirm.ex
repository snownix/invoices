defmodule SnownixWeb.AuthLive.Reconfirm do
  use SnownixWeb, :live_view

  alias Snownix.Accounts

  def mount(_, _, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, gettext("Resend Confirmation Instructions"))
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
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.auth_confirm_url(socket, :confirm, &1)
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext(
         "If your email is in our system and it has not been confirmed yet, " <>
           "you will receive an email with instructions shortly"
       )
     )
     |> redirect(to: Routes.auth_login_path(socket, :login))}
  end
end
