defmodule SnownixWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView

  alias Snownix.Accounts
  alias Snownix.Accounts.User

  def on_mount(:user, params, session, socket) do
    socket =
      socket
      |> fetch_locale(session)
      |> set_locale(params)
      |> assign(:current_user, find_current_user(session))

    {:cont, socket}
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
