defmodule SnownixWeb.Org.InvoiceLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.{Invoices, Customers}
  alias Snownix.Pagination
  alias Snownix.Invoices.Item

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    changeset = Invoices.change_invoice(invoice)
    items = Enum.map(invoice.items, &Invoices.change_item(&1))

    {:ok,
     socket
     |> assign(assigns)
     |> assign_customers()
     |> assign(:items, items)
     |> assign(:delete_items, [])
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset
      |> Ecto.Changeset.cast(invoice_params, [])
      |> Ecto.Changeset.cast_assoc(:items, with: &Item.changeset/2)

    changeset = changeset |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, items: changeset.changes.items)}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.action, invoice_params)
  end

  def handle_event("add-item", _, socket) do
    %{changeset: changeset, invoice: invoice, items: items} = socket.assigns

    items =
      items
      |> Enum.concat([
        Invoices.change_item(%Item{temp_id: get_temp_id(), invoice: invoice})
      ])

    changeset = Ecto.Changeset.put_assoc(changeset, :items, items)
    {:noreply, assign(socket, changeset: changeset, items: items)}
  end

  def handle_event("remove-item", %{"id" => id}, socket) do
    %{changeset: changeset, items: items, delete_items: delete_items} = socket.assigns

    items = Enum.reject(items, fn %{data: x} -> x.id === id or x.temp_id == id end)
    delete_items = Enum.filter(delete_items, fn %{data: x} -> x.id === id or x.temp_id == id end)

    changeset = Ecto.Changeset.put_assoc(changeset, :items, items)
    {:noreply, assign(socket, changeset: changeset, items: items, delete_items: delete_items)}
  end

  defp save_invoice(socket, :edit, invoice_params) do
    %{project: project, current_user: user, invoice: invoice, delete_items: delete_items} =
      socket.assigns

    case Invoices.delete_items(delete_items) do
      {:ok, _} ->
        case Invoices.update_invoice(invoice, project, user, invoice_params) do
          {:ok, _invoice} ->
            {:noreply,
             socket
             |> put_flash(:info, "invoice updated successfully")
             |> push_patch(to: socket.assigns.return_to)}

          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end

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

  def get_temp_id, do: :crypto.strong_rand_bytes(10) |> Base.url_encode64() |> binary_part(0, 10)
end
