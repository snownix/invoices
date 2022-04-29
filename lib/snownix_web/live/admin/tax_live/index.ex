defmodule SnownixWeb.Admin.TaxLive.Index do
  use SnownixWeb, :live_view

  alias Snownix.Projects
  alias Snownix.Projects.Tax

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :taxs, list_taxs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tax")
    |> assign(:tax, Projects.get_tax!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tax")
    |> assign(:tax, %Tax{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Taxs")
    |> assign(:tax, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tax = Projects.get_tax!(id)
    {:ok, _} = Projects.delete_tax(tax)

    {:noreply, assign(socket, :taxs, list_taxs())}
  end

  defp list_taxs do
    Projects.list_taxs()
  end
end
