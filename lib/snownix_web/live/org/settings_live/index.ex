defmodule SnownixWeb.Org.SettingsLive.Index do
  use SnownixWeb, :live_dashboard

  import Snownix.Geo
  alias Snownix.Organizations
  alias Snownix.Projects
  alias Snownix.Projects.Tax
  alias Snownix.Products
  alias Snownix.Products.Unit
  alias Snownix.Invoices
  alias Snownix.Invoices.Group

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
      id: "groups",
      title: "Groups",
      icon: "groups.svg",
      description: "Manage invoices & quotes groups, identifiers formatting."
    },
    %{
      id: "taxs",
      title: "Tax",
      icon: "tax.svg",
      description:
        "You can add or Remove Taxes as you please. We supports Taxes on Individual Items as well as on the invoice."
    },
    %{
      id: "units",
      title: "Unit",
      icon: "unit.svg",
      description: "Manage your project units to be used in the products."
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
     |> assign(:tab, select_tab())
     |> assign_taxs()
     |> assign_tax_changeset()
     |> assign_units()
     |> assign_unit_changeset()
     |> assign_groups()
     |> assign_group_changeset()
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
    %{project: project} = socket.assigns

    socket
    |> assign(%{
      changeset: Organizations.change_project(project, params),
      preferences_changeset: Organizations.change_project_preferences(project, params)
    })
  end

  def assign_tax_changeset(socket, params \\ %{}) do
    %{tax: tax, project: project, current_user: user} = socket.assigns

    socket
    |> assign(
      :tax_changeset,
      Projects.change_tax(tax, project, user, params)
    )
  end

  def assign_unit_changeset(socket, params \\ %{}) do
    %{unit: unit} = socket.assigns

    assign(socket, :unit_changeset, Products.change_unit(unit, params))
  end

  def assign_group_changeset(socket, params \\ %{}) do
    %{group: group} = socket.assigns

    assign(socket, :group_changeset, Invoices.change_group(group, params))
  end

  defp assign_taxs(socket, item \\ %Tax{}, action \\ :create) do
    item = Map.put(item, :percent_float, float_format(item.percent))

    socket
    |> assign(:tax, item)
    |> assign(:tax_action, action)
    |> assign(:taxs, Projects.list_taxs(socket.assigns.project))
  end

  defp assign_units(socket, item \\ %Unit{}, action \\ :create) do
    socket
    |> assign(:unit, item)
    |> assign(:unit_action, action)
    |> assign(:units, Products.list_units(socket.assigns.project))
  end

  defp assign_groups(socket, item \\ %Group{}, action \\ :create) do
    socket
    |> assign(:group, item)
    |> assign(:group_action, action)
    |> assign(:groups, Invoices.list_groups(socket.assigns.project))
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(:tab, select_tab(tab))}
  end

  # tax info
  def handle_event("tax-edit", %{"id" => id}, socket) do
    tax =
      Projects.get_tax!(id)
      |> Snownix.Repo.preload(:user)
      |> Snownix.Repo.preload(:project)

    {:noreply,
     socket
     |> assign_taxs(tax, :update)
     |> assign_tax_changeset()}
  end

  # Unit info
  def handle_event("unit-edit", %{"id" => id}, socket) do
    unit =
      Products.get_unit!(id)
      |> Snownix.Repo.preload(:user)
      |> Snownix.Repo.preload(:project)

    {:noreply,
     socket
     |> assign_units(unit, :update)
     |> assign_unit_changeset()}
  end

  def handle_event("unit-validate", %{"unit" => params}, socket) do
    changeset =
      socket.assigns.unit
      |> Products.change_unit(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> clear_flash()
     |> assign(:unit_changeset, changeset)}
  end

  def handle_event("unit-save", %{"unit" => params}, socket) do
    %{unit: unit, project: project, current_user: user, unit_action: action} = socket.assigns

    case apply_unit_action(action, unit, project, user, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_units(%Unit{}, :create)
         |> assign_unit_changeset()
         |> put_flash(:success, gettext("Units updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:unit_changeset, changeset)}
    end
  end

  # group info
  def handle_event("group-edit", %{"id" => id}, socket) do
    group =
      Invoices.get_group!(id)
      |> Snownix.Repo.preload(:user)
      |> Snownix.Repo.preload(:project)

    {:noreply,
     socket
     |> assign_groups(group, :update)
     |> assign_group_changeset()}
  end

  def handle_event("group-validate", %{"group" => params}, socket) do
    changeset =
      socket.assigns.group
      |> Invoices.change_group(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> clear_flash()
     |> assign(:group_changeset, changeset)}
  end

  def handle_event("group-save", %{"group" => params}, socket) do
    %{group: group, project: project, current_user: user, group_action: action} = socket.assigns

    case apply_group_action(action, group, project, user, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign_groups(%Group{}, :create)
         |> assign_group_changeset()
         |> put_flash(:success, gettext("groups updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:group_changeset, changeset)}
    end
  end

  def handle_event("tax-validate", %{"tax" => params}, socket) do
    %{tax: tax, project: project, current_user: user} = socket.assigns

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
    %{tax: tax, project: project, current_user: user, tax_action: action} = socket.assigns

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
    %{current_user: user, project: project} = socket.assigns

    case Organizations.update_project(project, params, user) do
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

  # group
  def handle_event("group-delete", %{"id" => id}, socket) do
    %{current_user: user, project: project} = socket.assigns

    group = Invoices.get_group!(project, id)
    Invoices.delete_group(group, project, user)

    {:noreply, socket |> assign_groups()}
  end

  # tax
  def handle_event("tax-delete", %{"id" => id}, socket) do
    %{current_user: user, project: project} = socket.assigns

    tax = Projects.get_tax!(id)
    Projects.delete_tax(tax, project, user)

    {:noreply, socket |> assign_taxs()}
  end

  # Unit
  def handle_event("unit-delete", %{"id" => id}, socket) do
    %{current_user: user, project: project} = socket.assigns

    unit = Products.get_unit!(id)
    Products.delete_unit(unit, project, user)

    {:noreply, socket |> assign_units()}
  end

  # logo
  def handle_event("validate", _, socket), do: {:noreply, socket}

  def handle_event("delete-logo", _, socket) do
    %{project: project} = socket.assigns

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

  def apply_tax_action(:create, _, project, user, params),
    do: Projects.create_tax(project, user, params)

  def apply_tax_action(:update, tax, project, user, params),
    do: Projects.update_tax(tax, project, user, params)

  def apply_unit_action(:create, _, project, user, params),
    do: Products.create_unit(project, user, params)

  def apply_unit_action(:update, unit, project, user, params),
    do: Products.update_unit(unit, project, user, params)

  def apply_group_action(:create, _, project, user, params),
    do: Invoices.create_group(project, user, params)

  def apply_group_action(:update, item, project, user, params),
    do: Invoices.update_group(item, project, user, params)

  defp handle_progress(:logo, entry, socket) do
    if entry.done? do
      %{project: project} = socket.assigns

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

  def tab(tabs, id), do: Enum.find(tabs, &(&1.id === id))

  # Upload messages
  defp error_to_string(:too_large), do: gettext("File size is too large, max allowed 2MB.")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files.")

  defp error_to_string(:not_accepted),
    do: gettext("You have selected an unacceptable file type, only images are accepted.")
end
