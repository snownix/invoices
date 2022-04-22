defmodule SnownixWeb.AuthLive.Register do
  use SnownixWeb, :live_view

  alias Snownix.Accounts

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:changeset, Accounts.user_register_changeset(%Accounts.User{}))
     |> assign(:page_title, gettext("Sign up"))}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %Accounts.User{}
      |> Accounts.user_register_changeset(user_params, uniq_email: false)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("create", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.auth_confirm_url(socket, :confirm, &1)
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext(
             "Registration completed successfully. please check your email to verify your account."
           )
         )
         |> redirect(to: Routes.auth_login_path(socket, :login))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)}
    end
  end
end
