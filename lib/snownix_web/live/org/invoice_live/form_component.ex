defmodule SnownixWeb.Org.InvoiceLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.{Invoices, Customers}
  alias Snownix.Pagination

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    changeset = Invoices.change_invoice(invoice)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_customers()
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
    %{project: project, current_user: user, invoice: invoice} = socket.assigns

    case Invoices.update_invoice(invoice, project, user, invoice_params) do
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

    invoice_params =
      Map.merge(invoice_params, %{"sequence_number" => Invoices.get_last_sequence_number()})

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

  def currencies_options() do
    Enum.map(Money.Currency.all(), fn {index, c} ->
      {"#{index} - #{c.name} #{c.symbol}", index}
    end)
  end

  defp assign_customers(socket) do
    %{project: project} = socket.assigns

    customers =
      Customers.list_customer_users(project)
      |> Pagination.page(1, per_page: 100)

    socket |> assign(customers: customers.items)
  end

  def customers_options(assigns) do
    assigns.customers
    |> Enum.map(fn c ->
      {"#{c.contact_name}", c.id}
    end)
  end
end
