defmodule SnownixWeb.Org.SettingsLive.Index do
  use SnownixWeb, :live_dashboard

  import Snownix.Geo
  alias Snownix.Organizations
  alias Snownix.Projects
  alias Snownix.Projects.Tax

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
    },
    %{
      id: "taxs",
      title: "Tax",
      icon: "tax.svg",
      description:
        "You can add or Remove Taxes as you please. We supports Taxes on Individual Items as well as on the invoice."
    }
  ]
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:tabs, @tabs)
     |> assign(:tab, select_tab())
     |> assign_taxs()
     |> assign_tax_changeset()
     |> assign_project_changeset()
     |> allow_upload(:logo,
       accept: ~w(.jpg .jpeg .png .gif .txt),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  defp assign_project_changeset(socket, params \\ %{}) do
    project = socket.assigns.project

    socket
    |> assign(
      :changeset,
      project |> Organizations.change_project(params)
    )
    |> assign(
      :preferences_changeset,
      socket.assigns.project
      |> Organizations.change_project_preferences(params)
    )
  end

  def assign_tax_changeset(socket, params \\ %{}) do
    tax = socket.assigns.tax
    user = socket.assigns.current_user
    project = socket.assigns.project

    socket
    |> assign(
      :tax_changeset,
      Projects.change_tax(tax, project, user, params)
    )
  end

  defp assign_taxs(socket, tax \\ %Tax{}, action \\ :create) do
    socket
    |> assign(:tax, tax)
    |> assign(:tax_action, action)
    |> assign(:taxs, Projects.list_taxs(socket.assigns.project))
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(:tab, select_tab(tab))}
  end

  # tax info
  def handle_event("tax-edit", %{"id" => id}, socket) do
    tax =
      Projects.get_tax!(id)
      |> Snownix.Repo.preload(:author)
      |> Snownix.Repo.preload(:project)

    {:noreply,
     socket
     |> assign_taxs(tax, :update)
     |> assign_tax_changeset()}
  end

  def handle_event("tax-validate", %{"tax" => params}, socket) do
    tax = socket.assigns.tax
    project = socket.assigns.project
    user = socket.assigns.current_user

    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :tax_changeset,
       tax
       |> Projects.change_tax(project, user, params)
       |> Map.put(:action, :validate)
     )}
  end

  def handle_event("tax-save", %{"tax" => params}, socket) do
    tax = socket.assigns.tax
    project = socket.assigns.project
    user = socket.assigns.current_user

    action = socket.assigns.tax_action

    case apply_tax_action(action, tax, project, user, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_taxs(%Tax{}, :create)
         |> assign_tax_changeset()
         |> put_flash(:success, gettext("Tax updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:tax_changeset, changeset)}
    end
  end

  # project info
  def handle_event("project-validate", %{"project" => params}, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :changeset,
       socket.assigns.project
       |> Organizations.change_project(params)
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
       |> Organizations.change_project_preferences(params)
       |> Map.put(:action, :validate)
     )}
  end

  # save
  def handle_event("project-save", %{"project" => params}, socket) do
    project = socket.assigns.project

    case Organizations.update_project(project, params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> assign(:project, project)
         |> assign_project_changeset(params)
         |> put_flash(:success, gettext("Project information updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  # tax
  def handle_event("tax-delete", %{"id" => id}, socket) do
    tax = Projects.get_tax!(id)
    Projects.delete_tax(tax)

    {:noreply, socket |> assign_taxs()}
  end

  # logo
  def handle_event("validate", _, socket), do: {:noreply, socket}

  def handle_event("delete-logo", _, socket) do
    project = socket.assigns.project

    if !is_nil(project.logo) do
      Snownix.Uploaders.LogoUploader.delete({project.logo, project})
    end

    case Organizations.update_project_logo(project, nil) do
      {:ok, project} ->
        {:noreply, socket |> assign(:project, project)}

      _ ->
        {:noreply, socket}
    end
  end

  def apply_tax_action(:create, tax, project, user, params),
    do: Projects.create_tax(tax, project, user, params)

  def apply_tax_action(:update, tax, project, user, params),
    do: Projects.update_tax(tax, project, user, params)

  defp handle_progress(:logo, entry, socket) do
    if entry.done? do
      project = socket.assigns.project

      consume_uploaded_entries(socket, :logo, fn meta, entry ->
        {:ok, project} =
          Organizations.update_project_logo(project, %Plug.Upload{
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
    Enum.map(Money.Currency.all(), fn {index, c} ->
      {"#{index} - #{c.name} #{c.symbol}", index}
    end)
  end

  def fiscal_year_options() do
    Snownix.Helpers.Model.fiscal_years() |> Enum.map(fn c -> {c.title, c.id} end)
  end

  def date_format_options() do
    Snownix.Helpers.Model.date_formats()
    |> Enum.map(fn c -> {Calendar.strftime(Date.utc_today(), c), c} end)
  end

  def time_zone_options(), do: Snownix.Helpers.Model.timezones()

  # Upload messages
  defp error_to_string(:too_large), do: gettext("File size is too large, max allowed 2MB.")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files.")

  defp error_to_string(:not_accepted),
    do: gettext("You have selected an unacceptable file type, only images are accepted.")
end
