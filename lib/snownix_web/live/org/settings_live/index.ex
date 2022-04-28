defmodule SnownixWeb.Org.SettingsLive.Index do
  use SnownixWeb, :live_dashboard

  import Snownix.Geo
  alias Snownix.Organization
  alias Snownix.Organization.Project

  @tabs [
    %{
      id: "project",
      title: "Project",
      icon: "project.svg",
      description:
        "Information about your company that will be displayed on invoices, estimates and other documents."
    },
    %{
      id: "preferences",
      title: "Preferences",
      icon: "preferences.svg",
      description: "Advanced preferences for the billing system, formats, currency etc."
    },
    %{
      id: "notifications",
      title: "Notifications",
      icon: "notification.svg",
      description: "Which email notifications would you like to receive when something changes"
    }
  ]
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:tabs, @tabs)
     |> allow_upload(:logo,
       accept: ~w(.jpg .jpeg .png .gif .txt),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign(:tab, select_tab())
     |> assign_changeset()}
  end

  defp assign_changeset(socket, attrs \\ %{}) do
    socket
    |> assign(:changeset, socket.assigns.project |> Organization.change_project(attrs))
    |> assign(
      :preferences_changeset,
      socket.assigns.project |> Organization.change_project_preferences(attrs)
    )
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(:tab, select_tab(tab))}
  end

  # project info
  def handle_event("project-validate", %{"project" => params}, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :changeset,
       socket.assigns.project
       |> Organization.change_project(params)
       |> Map.put(:action, :validate)
     )}
  end

  # preferences
  def handle_event("preferences-validate", %{"project" => params}, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :preferences_changeset,
       socket.assigns.project
       |> Organization.change_project_preferences(params)
       |> Map.put(:action, :validate)
     )}
  end

  # save
  def handle_event("project-save", %{"project" => params}, socket) do
    project = socket.assigns.project

    case Organization.update_project(project, params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> assign(:project, project)
         |> assign_changeset(params)
         |> put_flash(:success, gettext("Project information updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  # logo
  def handle_event("validate", _, socket), do: {:noreply, socket}

  def handle_event("delete-logo", _, socket) do
    project = socket.assigns.project

    if !is_nil(project.logo) do
      Snownix.Uploaders.LogoUploader.delete({project.logo, project})
    end

    case Organization.update_project_logo(project, nil) do
      {:ok, project} ->
        {:noreply, socket |> assign(:project, project)}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_progress(:logo, entry, socket) do
    if entry.done? do
      project = socket.assigns.project

      consume_uploaded_entries(socket, :logo, fn meta, entry ->
        {:ok, project} =
          Organization.update_project_logo(project, %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          })

        {:ok, Snownix.Uploaders.LogoUploader.url({project.logo, project}, :original)}
      end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Tabs
  defp select_tab(tab \\ nil) do
    Enum.find(@tabs, List.first(@tabs), &(&1.title == tab))
  end

  def is_active_tab(current, tab) do
    current.title == tab.title
  end

  def currencies_options() do
    Money.Currency.all()
    |> Enum.map(fn {index, c} -> {"#{index} - #{c.name} #{c.symbol}", index} end)
  end

  def fiscal_year_options() do
    Project.fiscal_years() |> Enum.map(fn c -> {c.title, c.id} end)
  end

  def date_format_options() do
    Project.date_formats() |> Enum.map(fn c -> {Calendar.strftime(Date.utc_today(), c), c} end)
  end

  def time_zone_options(), do: Project.timezones()

  # Upload messages
  defp error_to_string(:too_large), do: gettext("File size is too large, max allowed 2MB.")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files.")

  defp error_to_string(:not_accepted),
    do: gettext("You have selected an unacceptable file type, only images are accepted.")
end
