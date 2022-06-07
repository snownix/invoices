defmodule SnownixWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales Gettext.known_locales(SnownixWeb.Gettext)

  def init(_options), do: nil

  def call(conn, _options) do
    case fetch_locale_from(conn) do
      nil ->
        conn
    end
  end

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"] || get_session(conn, :locale))
    |> check_locale()
  end

  defp check_locale(locale) do
    if locale in @supported_locales do
      locale
    else
      nil
    end
  end
end
