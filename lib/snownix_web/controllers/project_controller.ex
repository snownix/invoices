defmodule SnownixWeb.ProjectController do
  use SnownixWeb, :controller

  alias Snownix.Organization

  def open(conn, %{"id" => id}) do
    project = Organization.get_project_by_user(conn.assigns[:current_user], id)

    if project do
      log_in_project(conn, id)
    else
      conn
      |> put_flash(:error, gettext("Project not found !"))
      |> redirect(to: Routes.project_index_path(conn, :index))
    end
  end

  def log_in_project(conn, id) do
    conn
    |> put_session(:project_id, id)
    |> redirect(to: Routes.project_dashboard_path(conn, :index))
  end

  def leave(conn, _) do
    conn
    |> delete_session(:project_id)
    |> redirect(to: Routes.project_index_path(conn, :index))
  end
end
