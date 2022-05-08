defmodule SnownixWeb.Org.CustomerLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Customers

  @impl true
  def update(%{customer: customer} = assigns, socket) do
    changeset = Customers.change_user(customer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => customer_params}, socket) do
    changeset =
      socket.assigns.customer
      |> Customers.change_user(customer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => customer_params}, socket) do
    save_customer(socket, socket.assigns.action, customer_params)
  end

  defp save_customer(socket, :edit, customer_params) do
    case Customers.update_user(socket.assigns.customer, customer_params) do
      {:ok, _customer} ->
        {:noreply,
         socket
         |> put_flash(:info, "customer updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_customer(socket, :new, customer_params) do
    project = socket.assigns.project
    user = socket.assigns.current_user

    case Customers.create_user(project, user, customer_params) do
      {:ok, _customer} ->
        {:noreply,
         socket
         |> put_flash(:info, "customer created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
