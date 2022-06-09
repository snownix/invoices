defmodule SnownixWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales Gettext.known_locales(SnownixWeb.Gettext)

  def init(_options), do: nil

  def call(conn, _options) do
    case fetch_locale_from(conn) do
      nil ->
        conn

      locale ->
        conn |> set_locale_to(locale)
    end
  end

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"] || get_session(conn, :locale))
    |> check_locale()
  end

  defp set_locale_to(conn, locale) do
    SnownixWeb.Gettext |> Gettext.put_locale(locale)

    conn = conn |> put_session(:locale, locale)
    put_resp_cookie(conn, "locale", locale)
  end

  defp check_locale(locale) when locale in @supported_locales, do: locale
  defp check_locale(_), do: nil
end
