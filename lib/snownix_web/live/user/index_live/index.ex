defmodule SnownixWeb.IndexLive.Index do
  use SnownixWeb, :live_dashboard

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Home"))
     |> assign_meta_tags()}
  end

  defp assign_meta_tags(socket) do
    socket
    |> put_meta_tags(%{
      page_title: gettext("Home")
    })
  end
end
