defmodule SnownixWeb.Admin.ActivityLive.Show do
  use SnownixWeb, :live_view

  alias Snownix.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:activity, Projects.get_activity!(id))}
  end

  defp page_title(:show), do: "Show Activity"
  defp page_title(:edit), do: "Edit Activity"
end
