defmodule SnownixWeb.Admin.TaxLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Projects

  @impl true
  def update(%{tax: tax} = assigns, socket) do
    changeset = Projects.change_tax(tax)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"tax" => tax_params}, socket) do
    changeset =
      socket.assigns.tax
      |> Projects.change_tax(tax_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tax" => tax_params}, socket) do
    save_tax(socket, socket.assigns.action, tax_params)
  end

  defp save_tax(socket, :edit, tax_params) do
    case Projects.update_tax(socket.assigns.tax, tax_params) do
      {:ok, _tax} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tax updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_tax(socket, :new, tax_params) do
    case Projects.create_tax(tax_params) do
      {:ok, _tax} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tax created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
