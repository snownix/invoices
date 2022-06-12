defmodule SnownixWeb.Admin.UnitLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Products

  @impl true
  def update(%{unit: unit, project: project, current_user: user} = assigns, socket) do
    changeset = Products.change_unit(unit, project, user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"unit" => unit_params}, socket) do
    %{project: project, current_user: user} = socket.assigns

    changeset =
      socket.assigns.unit
      |> Products.change_unit(project, user, unit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"unit" => unit_params}, socket) do
    save_unit(socket, socket.assigns.action, unit_params)
  end

  defp save_unit(socket, :edit, unit_params) do
    case Products.update_unit(socket.assigns.unit, unit_params) do
      {:ok, _unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_unit(socket, :new, unit_params) do
    case Products.create_unit(unit_params) do
      {:ok, _unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
