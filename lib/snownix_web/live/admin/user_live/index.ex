defmodule SnownixWeb.Admin.UserLive.Index do
  use SnownixWeb, :live_view

  alias Snownix.Customers
  alias Snownix.Customers.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :customer_users, list_customer_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Customers.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Customer users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Customers.get_user!(id)
    {:ok, _} = Customers.delete_user(user)

    {:noreply, assign(socket, :customer_users, list_customer_users())}
  end

  defp list_customer_users do
    Customers.list_customer_users()
  end
end
