defmodule SnownixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView

  alias Snownix.{Accounts, Organizations}
  alias Snownix.Accounts.User
  alias Snownix.Organizations.Project

  def on_mount(:user, params, session, socket) do
    socket =
      socket
      |> fetch_locale(session)
      |> set_locale(params)
      |> assign(:current_user, find_current_user(session))

    {:cont, socket}
  end

  def on_mount(:project, _params, session, socket) do
    user = socket.assigns.current_user

    if !is_nil(user) do
      case find_current_project(user, session) do
        nil ->
          {:cont, socket}

        project ->
          {:cont,
           socket
           |> assign(:project, project)}
      end
    else
      {:cont, socket}
    end
  end

  defp find_current_project(user, session) do
    with project_id when not is_nil(project_id) <- session["project_id"],
         %Project{} = project <-
           Organizations.get_project_by_user(user, project_id),
         do: project
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

  def set_locale(socket, %{"locale" => locale}) do
    Gettext.put_locale(SnownixWeb.Gettext, locale)

    socket
    |> assign(:locale, locale)
  end

  def set_locale(socket, _), do: socket

  defp fetch_locale(socket, session) do
    locale =
      session["locale"] || Application.get_env(:snownix, SnownixWeb.Gettext)[:default_locale]

    Gettext.put_locale(SnownixWeb.Gettext, locale)

    socket |> assign(:locale, locale)
  end
end
