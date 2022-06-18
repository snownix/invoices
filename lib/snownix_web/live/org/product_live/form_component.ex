defmodule SnownixWeb.Org.ProductLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Products

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset =
      product
      |> Map.delete(:category)
      |> Products.change_product()

    {:ok,
     socket
     |> assign(assigns)
     |> fetch_categories()
     |> fetch_units(product)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "selected-item",
        %{"id" => unit_id, "type" => "unit", "name" => unit_name},
        socket
      ) do
    {:noreply, assign(socket, :selected_unit, {unit_id, unit_name})}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, %{"category" => category_id} = product_params) do
    %{project: project, current_user: user} = socket.assigns

    category =
      if String.length(category_id) > 0 do
        Products.get_category(project_id(socket), category_id)
      else
        nil
      end

    case Products.update_product(socket.assigns.product, project, user, category, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "product updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :new, %{"category" => category_id} = product_params) do
    %{project: project, current_user: user} = socket.assigns

    category = Products.get_category!(project_id(socket), category_id)

    case Products.create_product(project, user, category, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "product created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def currencies_options() do
    Enum.map(Money.Currency.all(), fn {index, c} ->
      {"#{index} - #{c.name} #{c.symbol}", index}
    end)
  end

  defp project_id(%{assigns: %{project: %{id: id}}}), do: id

  def fetch_categories(socket) do
    categories =
      socket
      |> project_id()
      |> Products.list_categories()
      |> Enum.map(&{&1.name, &1.id})

    assign(socket, :categories, categories)
  end

  def fetch_units(socket, %{unit_id: id}) do
    units =
      Products.list_units()
      |> Enum.map(&{&1.id, &1.name})

    selected_unit =
      units
      |> Enum.find_value(fn {unit_id, unit_name} ->
        if unit_id == id, do: {unit_id, unit_name}
      end)

    assign(socket, units: units, selected_unit: selected_unit)
  end
end
