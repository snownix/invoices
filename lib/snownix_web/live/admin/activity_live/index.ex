defmodule SnownixWeb.Admin.ActivityLive.Index do
  use SnownixWeb, :live_view

  alias Snownix.Projects
  alias Snownix.Projects.Activity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :activities, list_activities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity")
    |> assign(:activity, Projects.get_activity!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Activity")
    |> assign(:activity, %Activity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activities")
    |> assign(:activity, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity = Projects.get_activity!(id)
    {:ok, _} = Projects.delete_activity(activity)

    {:noreply, assign(socket, :activities, list_activities())}
  end

  defp list_activities do
    Projects.list_activities()
  end
end
