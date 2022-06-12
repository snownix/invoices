defmodule SnownixWeb.Org.CustomerLive.AddressesComponent do
  use SnownixWeb, :live_component
  import Snownix.Helpers.TablePub

  import Snownix.Geo
  alias Snownix.Customers
  alias Snownix.Customers.Address

  @impl true
  def update(assigns, socket) do
    if connected?(socket),
      do: Snownix.Customers.subscribe(assigns.project.id, assigns.customer.id)

    socket =
      socket
      |> assign(assigns)
      |> assign(%{
        addresses: assigns.customer.addresses,
        address: nil,
        action: :index
      })

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    %{project: project, current_user: user} = socket.assigns

    case Customers.delete_address(get_address(id), project, user) do
      {:ok, _} ->
        {:noreply, assign(socket, :action, :index)}

      {:error, changeset} ->
        {:norpely, socket |> put_changeset_errors(changeset)}
    end
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = Customers.change_address(%Address{})
    {:noreply, assign(socket, changeset: changeset, action: :new, address: %Address{})}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    address = get_address(id)
    changeset = Customers.change_address(address)
    {:noreply, assign(socket, changeset: changeset, action: :edit, address: address)}
  end

  @impl true
  def handle_event("validate", %{"address" => params}, socket) do
    %{address: address} = socket.assigns
    changeset = Customers.change_address(address, params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"address" => params}, socket) do
    %{action: action} = socket.assigns
    save_address(socket, action, params)
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, action: :index)}
  end

  @impl true
  def handle_event("select-default", %{"id" => id}, socket) do
    %{project: project, current_user: user, addresses: addresses} = socket.assigns
    address = get_address(id)

    case Customers.change_default_address(address, project, user, addresses) do
      {:ok, _address} ->
        {:noreply, put_flash(socket, :success, "Address has been selected as default")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Selecting address as default has been failed")}
    end
  end

  def handle_info({Customers, [:address, type], address}, socket) do
    handle_table_pub(
      __MODULE__,
      socket,
      :addresses,
      :address,
      {Customers, [:address, type], address}
    )
  end

  def save_address(socket, :new, params) do
    %{project: project, current_user: user, customer: customer} = socket.assigns

    case Customers.create_address(params, project, user, customer) do
      {:ok, _address} ->
        {:noreply,
        socket
        |> put_flash(:success, "New address has been created")
        |> assign(action: :index)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def save_address(socket, :edit, params) do
    %{project: project, current_user: user, address: address} = socket.assigns

    case Customers.update_address(address, project, user, params) do
      {:ok, _address} ->
        {:noreply,
        socket
        |> put_flash(:success, "Address has been updated")
        |> assign(action: :index)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp get_address(id) do
    Customers.get_address!(id)
  end
end
