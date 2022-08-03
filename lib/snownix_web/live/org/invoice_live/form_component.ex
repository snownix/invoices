defmodule SnownixWeb.Org.InvoiceLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Pagination
  alias Snownix.Invoices.Item
  alias Snownix.{Invoices, Customers}

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
    %{invoice: invoice} = socket.assigns

    changeset =
      invoice
      |> Invoices.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.action, invoice_params)
  end

  def handle_event("new-item", _, %{assigns: assigns} = socket) do
    changeset = put_new_invoice_item(assigns)

    {:noreply,
     socket
     |> assign(changeset: changeset)}
  end

  def handle_event("remove-item", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> remove_invoice_item(id)}
  end

  defp put_new_invoice_item(%{changeset: changeset, invoice: invoice} = _assigns) do
    items = changeset.changes[:items] || changeset.data.items

    items =
      items ++
        [
          Invoices.change_item(%Item{temp_id: get_temp_id(), invoice: invoice})
        ]

    changeset |> Map.update!(:changes, &Map.put(&1, :items, items))
  end

  defp remove_invoice_item(%{assigns: assigns} = socket, id) do
    %{changeset: changeset} = assigns

    items = changeset.changes[:items] || changeset.data.items

    items =
      Enum.filter(items, fn item ->
        case item do
          %{data: data} -> data.id !== id and data.temp_id !== id
          data -> data.id !== id
        end
      end)

    changeset = changeset |> Map.update!(:changes, &Map.put(&1, :items, items))

    socket
    |> assign(changeset: changeset)
  end

  defp save_invoice(socket, :new, invoice_params) do
    %{project: project, current_user: user, return_to: return_to} = socket.assigns

    invoice_params =
      Map.merge(invoice_params, %{"sequence_number" => Invoices.get_last_sequence_number()})

    case Invoices.create_invoice(project, user, invoice_params) do
      {:ok, _invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice created successfully")
         |> push_patch(to: return_to)}

      {:error, changeset} ->
        {:noreply, handle_changeset_state(socket, changeset)}
    end
  end

  defp save_invoice(socket, :edit, invoice_params) do
    %{
      project: project,
      current_user: user,
      invoice: invoice,
      return_to: return_to
    } = socket.assigns

    invoice_params = invoice_params |> put_default_items()

    case Invoices.update_invoice(invoice, project, user, invoice_params) do
      {:ok, _invoice} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Invoice updated successfully")
          |> push_patch(to: return_to)
        }

      {:error, changeset} ->
        {:noreply, handle_changeset_state(socket, changeset)}
    end
  end

  defp handle_changeset_state(socket, changeset) do
    IO.inspect(changeset)

    socket
    |> put_changeset_errors(changeset)
    |> assign(:changeset, changeset)
  end

  defp put_default_items(invoice_items) do
    Map.put_new(invoice_items, "items", [])
  end

  defp assign_customers(socket) do
    %{project: project} = socket.assigns

    customers =
      Customers.list_customer_users(project)
      |> Pagination.page(1, per_page: 100)

    socket |> assign(customers: customers.items)
  end

  def customers_options(%{customers: customers} = _assigns) do
    Enum.map(customers, fn c ->
      {"#{c.contact_name}", c.id}
    end)
  end

  def get_temp_id(),
    do: :crypto.strong_rand_bytes(10) |> Base.url_encode64() |> binary_part(0, 10)

  def col_span(val), do: (val && 1) || 0

  def currencies_options() do
    Enum.map(Money.Currency.all(), fn {index, c} ->
      {"#{index} - #{c.name} #{c.symbol}", index}
    end)
  end
end
