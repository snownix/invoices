defmodule SnownixWeb.Admin.AddressLive.Index do
  use SnownixWeb, :live_view

  alias Snownix.Customers
  alias Snownix.Customers.Address

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :addresses, list_addresses())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Address")
    |> assign(:address, Customers.get_address!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Address")
    |> assign(:address, %Address{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Addresses")
    |> assign(:address, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    address = Customers.get_address!(id)
    {:ok, _} = Customers.delete_address(address)

    {:noreply, assign(socket, :addresses, list_addresses())}
  end

  defp list_addresses do
    Customers.list_addresses()
  end
end
