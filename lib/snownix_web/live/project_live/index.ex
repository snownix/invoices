defmodule SnownixWeb.ProjectLive.Index do
  use SnownixWeb, :live_dashboard

  alias Snownix.Repo
  alias Snownix.Organizations

  def mount(_, _, socket) do
    {
      :ok,
      socket
      |> fetch()
    }
  end

  defp fetch(socket) do
    user = socket.assigns.current_user

    projects = Organizations.user_list_projects(user)
    socket |> assign(projects: projects, page_title: "My Projects")
  end
end
