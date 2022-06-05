defmodule SnownixWeb.Org.CategoryLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Products

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Products.change_category(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Products.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    %{project: project, current_user: user} = socket.assigns

    case Products.update_category(socket.assigns.category, category_params, project, user) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "category updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    %{project: project, current_user: user} = socket.assigns

    case Products.create_category(project, user, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "category created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
