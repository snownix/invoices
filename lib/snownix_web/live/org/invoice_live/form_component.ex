defmodule SnownixWeb.Org.InvoiceLive.FormComponent do
  use SnownixWeb, :live_component

  alias Snownix.Pagination
  alias Snownix.Invoices.Item
  alias Snownix.Customers.User, as: Customer
  alias Snownix.Invoices.Address, as: IAddress
  alias Snownix.Customers.Address, as: CAddress
  alias Snownix.{Invoices, Customers}

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    changeset = Invoices.change_invoice(invoice)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_customers()
     |> assign_selected_customer()
     |> assign_addresses()
     |> assign_billing_address()
     |> assign_shipping_address()}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    %{invoice: invoice} = socket.assigns

    changeset =
      invoice
      |> Invoices.change_invoice(invoice_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(changeset: changeset)
      |> assign_addresses()

    {:noreply, socket}
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

  def handle_event(
        "search-select-item",
        %{"id" => id, "name" => name, "type" => type},
        socket
      ) do
    {:noreply,
     case type do
       "customer" ->
         socket |> assign(:selected_customer, {id, name})

       "billing_address" ->
         socket
         |> assign(:selected_billing_address, {id, name})
         |> assign_new_addresses(:billing_address)

       "shipping_address" ->
         socket
         |> assign(:selected_shipping_address, {id, name})
         |> assign_new_addresses(:shipping_address)
     end}
  end

  def handle_event("search-filter-items", input, socket) when is_binary(input) do
    {:noreply, socket |> assign_customers(input)}
  end

  defp assign_new_addresses(socket, :billing_address) do
    %{project: project, changeset: changeset, selected_billing_address: sba} = socket.assigns
    {id, _name} = sba

    address = Customers.get_address!(project, id)

    socket |> assign(changeset: copy_address(changeset, :billing_address, address))
  end

  defp assign_new_addresses(socket, :shipping_address) do
    %{project: project, changeset: changeset, selected_shipping_address: sba} = socket.assigns
    {id, _name} = sba

    address = Customers.get_address!(project, id)

    socket |> assign(changeset: copy_address(changeset, :shipping_address, address))
  end

  defp copy_address(changeset, field_name, address) do
    changeset_address =
      Ecto.Changeset.get_field(
        changeset,
        field_name
      ) || Invoices.change_address(%Snownix.Invoices.Address{})

    changeset_address = Ecto.Changeset.change(changeset_address)

    changeset_address =
      [:street, :street_2, :city, :state, :zip, :country]
      |> Enum.reduce(changeset_address, fn field, acc ->
        Ecto.Changeset.put_change(acc, field, Map.get(address, field))
      end)

    Ecto.Changeset.put_change(changeset, field_name, changeset_address)
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
    socket
    |> put_changeset_errors(changeset)
    |> assign(:changeset, changeset)
  end

  defp put_default_items(invoice_items) do
    Map.put_new(invoice_items, "items", [])
  end

  defp assign_customers(socket, search_term \\ nil) do
    %{project: project} = socket.assigns

    customers =
      Customers.list_customers(project, search_term)
      |> Enum.map(fn row ->
        {row.id, item_label(row)}
      end)

    socket |> assign(customers: customers)
  end

  defp assign_addresses(socket, search_term \\ nil) do
    %{project: project, selected_customer: selected_customer} = socket.assigns

    case selected_customer do
      {id, name} ->
        addresses =
          Customers.list_customer_addresses(project, %Customer{id: id}, search_term)
          |> Enum.map(fn row ->
            {row.id, item_label(row)}
          end)

        socket |> assign(addresses: addresses)

      _ ->
        socket |> assign(addresses: [])
    end
  end

  defp assign_billing_address(%{assigns: assigns} = socket) do
    %{changeset: changeset, project: project} = assigns

    case Ecto.Changeset.get_field(changeset, :billing_address) do
      nil ->
        socket |> assign(:selected_billing_address, nil)

      address ->
        socket |> assign(:selected_billing_address, {address.id, item_label(address)})
    end
  end

  defp assign_shipping_address(%{assigns: assigns} = socket) do
    %{changeset: changeset, project: project} = assigns

    case Ecto.Changeset.get_field(changeset, :shipping_address) do
      nil ->
        socket |> assign(:selected_shipping_address, nil)

      address ->
        socket |> assign(:selected_shipping_address, {address.id, item_label(address)})
    end
  end

  defp assign_selected_customer(%{assigns: assigns} = socket) do
    %{changeset: changeset, project: project} = assigns

    id = Ecto.Changeset.get_field(changeset, :customer_id)

    case id do
      nil ->
        socket |> assign(:selected_customer, nil)

      id ->
        customer = Customers.get_user!(project, id)
        socket |> assign(:selected_customer, {id, item_label(customer)})
    end
  end

  def get_temp_id(),
    do: :crypto.strong_rand_bytes(10) |> Base.url_encode64() |> binary_part(0, 10)

  def col_span(val), do: (val && 1) || 0

  def currencies_options() do
    Enum.map(Money.Currency.all(), fn {index, c} ->
      {"#{index} - #{c.name} #{c.symbol}", index}
    end)
  end

  defp item_label(%IAddress{} = row) do
    [:country, :city, :street] |> Enum.map(&Map.get(row, &1)) |> Enum.join(", ")
  end

  defp item_label(%CAddress{} = row) do
    [:country, :city, :street] |> Enum.map(&Map.get(row, &1)) |> Enum.join(", ")
  end

  defp item_label(%Customer{} = row) do
    [:name, :contact_name] |> Enum.map(&Map.get(row, &1)) |> Enum.join(", ")
  end

  defp item_label(nil), do: nil
end
