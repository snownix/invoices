defmodule SnownixWeb.Org.InvoiceLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Invoices

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    changeset = Invoices.change_invoice(invoice)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset =
      socket.assigns.invoice
      |> Invoices.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.action, invoice_params)
  end

  defp save_invoice(socket, :edit, invoice_params) do
    %{project: project, current_user: user} = socket.assigns

    case Invoices.update_invoice(socket.assigns.invoice, invoice_params, project, user) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "invoice updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_invoice(socket, :new, invoice_params) do
    %{project: project, current_user: user} = socket.assigns

    case Invoices.create_invoice(project, user, invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "invoice created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
