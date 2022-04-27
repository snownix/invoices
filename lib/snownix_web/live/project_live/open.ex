defmodule SnownixWeb.ProjectLive.Open do
  use SnownixWeb, :live_dashboard

  alias Snownix.Repo
  alias Snownix.Organization

  def mount(_, _, socket) do
    {
      :ok,
      socket
    }
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, socket |> fetch(id)}
  end

  defp fetch(socket, id) do
    project =
      Organization.get_project!(id)
      |> Repo.preload(:users)

    socket
    |> assign(project: project, page_title: project.name)
  end
end
