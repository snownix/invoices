defmodule SnownixWeb.Admin.CategoryLive.Show do
  use SnownixWeb, :live_view

  alias Snownix.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, Products.get_category!(id))}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
end
