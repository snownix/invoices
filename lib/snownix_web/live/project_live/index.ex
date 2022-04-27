defmodule SnownixWeb.ProjectLive.Index do
  use SnownixWeb, :live_dashboard

  alias Snownix.Repo
  alias Snownix.Organization

  def mount(_, _, socket) do
    {
      :ok,
      socket
      |> fetch()
    }
  end

  defp fetch(socket) do
    projects = Organization.list_projects() |> Repo.preload(:users)
    socket |> assign(projects: projects, page_title: "My Projects")
  end
end
