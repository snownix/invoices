defmodule SnownixWeb.Org.InvoiceLive.Index do
  use SnownixWeb, :live_dashboard
  import Snownix.Helpers.TablePub

  alias Snownix.Pagination

  alias Snownix.Invoices
  alias Snownix.Invoices.Invoice

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Snownix.Invoices.subscribe(project_id(socket))

    {:ok,
     socket
     |> assign(:table, %{
       page: 1,
       limit: 20,
       order: :desc,
       order_by: :inserted_at
     })
     |> assign(all_selected: false, selected_items: [])
     |> fetch()}
  end

  @impl true
  def handle_info({Invoices, [:invoice, type], result}, socket) do
    handle_table_pub(
      __MODULE__,
      socket,
      :invoices,
      :invoice,
      {Invoices, [:invoice, type], result}
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     case params do
       %{"id" => id} ->
         if connected?(socket),
           do: Snownix.Invoices.subscribe(project_id(socket), id)

         socket |> fetch_one(id)

       _ ->
         socket
     end
     |> apply_action(socket.assigns.live_action)}
  end

  @impl true
  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, socket |> push_patch(to: Routes.org_invoice_index_path(socket, :show, id))}
  end

  def handle_event("table", %{"table" => table_params}, socket) do
    %{"limit" => limit, "page" => page} = table_params

    {:noreply,
     socket
     |> assign_table_limit(limit)
     |> assign_table_page(page)
     |> fetch()}
  end

  def handle_event("page", %{"page" => page}, socket) do
    {:noreply, socket |> assign_table_page(page) |> fetch()}
  end

  def handle_event("order", %{"order" => order}, socket) do
    {:noreply, socket |> assign_table_order(order) |> fetch()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    %{project: project, current_user: user} = socket.assigns

    {:ok, _} = Invoices.delete_invoice(invoice_id(project.id, id), project, user)

    {:noreply, fetch(socket)}
  end

  def handle_event("delete-selected", _, socket) do
    {:ok, _} = Invoices.delete_invoices(project_id(socket), socket.assigns.selected_items)

    {:noreply, fetch(socket) |> assign(selected_items: [])}
  end

  def handle_event("clone-selected", _, socket) do
    {:ok, %{insert_all: {_, ids}}} =
      Invoices.clone_invoices(project_id(socket), socket.assigns.selected_items)

    {:noreply, fetch(socket) |> assign(selected_items: ids |> Enum.map(& &1.id))}
  end

  def handle_event("select", params, socket) do
    %{"id" => id} = params

    {:noreply,
     socket
     |> select_item(id)
     |> update_selected()}
  end

  defp apply_action(socket, :edit) do
    socket
    |> assign(:page_title, "Edit Invoice")
  end

  defp apply_action(socket, :new) do
    %{project: project} = socket.assigns

    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, %Invoice{
      invoice_number: "INV-00000000",
      currency: project.currency,
      tax_per_item: project.tax_per_item,
      from_date: Timex.today(),
      due_date: Timex.shift(Timex.today(), months: project.due_duration),
      items: [
        %Invoices.Item{temp_id: SnownixWeb.Org.InvoiceLive.FormComponent.get_temp_id()}
      ]
    })
  end

  defp apply_action(socket, :show) do
    %{invoice: invoice} = socket.assigns

    socket
    |> assign(:page_title, invoice.title)
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:invoice, nil)
    |> assign(:page_title, "Listing Invoices")
  end

  def fetch(socket) do
    socket |> list_invoices() |> update_selected()
  end

  def fetch_one(%{assigns: %{project: project}} = socket, id) do
    socket
    |> assign(:invoice, invoice_id(project.id, id))
  end

  def push_index(socket) do
    socket |> push_patch(to: Routes.org_invoice_index_path(socket, :index))
  end

  defp invoice_id(project_id, id) do
    Invoices.get_invoice!(project_id, id)
    |> Invoices.invoice_customer()
    |> Invoices.invoice_items()
  end

  defp project_id(%{assigns: %{project: %{id: id}}}) do
    id
  end

  defp list_invoices(socket) do
    %{project: project, table: %{page: page, limit: limit, order: order, order_by: order_by}} =
      socket.assigns

    pagination =
      Invoices.list_invoices(project, order_by: order_by, order: order)
      |> Pagination.page(page, per_page: limit)

    pagination = %{
      pagination
      | items: pagination.items |> Invoices.invoice_customer()
    }

    socket
    |> assign(:pagination, pagination)
    |> assign(:invoices, pagination.items)
  end

  defp assign_table_limit(socket, limit) do
    limit = String.to_integer(limit)

    case limit >= 1 and limit <= 100 do
      true ->
        socket |> assign(:table, %{socket.assigns.table | limit: limit})

      _ ->
        socket
    end
  end

  defp assign_table_page(socket, page) do
    page = String.to_integer(page)

    case page >= 1 and page <= socket.assigns.pagination.total do
      true ->
        socket |> assign(:table, %{socket.assigns.table | page: page})

      _ ->
        socket
    end
  end

  defp assign_table_order(socket, order) do
    order = String.to_atom(order)

    case order in Invoices.Invoice.__schema__(:fields) do
      true ->
        socket
        |> assign(:table, %{
          socket.assigns.table
          | order: order_by_toggle(socket),
            order_by: order
        })

      _ ->
        socket
    end
  end

  defp order_by_toggle(socket) do
    if socket.assigns.table.order == :asc do
      :desc
    else
      :asc
    end
  end

  defp select_item(socket, id) do
    %{
      invoices: invoices,
      all_selected: all_selected,
      selected_items: selected_items
    } = socket.assigns

    invoices =
      invoices
      |> Enum.map(fn item ->
        if id === "all" do
          %{item | selected: !all_selected}
        else
          if item.id === id do
            toggle_select(item)
          else
            item
          end
        end
      end)

    selected_ids = Enum.filter(invoices, &(&1.selected == true)) |> Enum.map(& &1.id)
    un_selected_ids = Enum.filter(invoices, &(&1.selected == false)) |> Enum.map(& &1.id)

    selected_items =
      (selected_items ++ selected_ids)
      |> Enum.uniq()
      |> Enum.reject(&Enum.member?(un_selected_ids, &1))

    socket
    |> assign(
      invoices: invoices,
      selected_items: selected_items
    )
  end

  defp toggle_select(item) do
    %{item | selected: !item.selected}
  end

  defp update_selected(socket) do
    %{invoices: invoices, selected_items: selected_items} = socket.assigns

    invoices =
      invoices
      |> Enum.map(fn item ->
        if Enum.member?(selected_items, item.id) do
          %{item | selected: true}
        else
          item
        end
      end)

    socket
    |> assign(:invoices, invoices)
    |> assign(
      :all_selected,
      is_nil(Enum.find(invoices, &(&1.selected == false))) && Enum.count(invoices) > 0
    )
  end

  def many_selected(assigns) do
    Enum.count(assigns.selected_items) > 0
  end

  def render_col(assigns, name, title) do
    ~H"""
      <th class="order__btn" phx-click="order" phx-value-order={Atom.to_string(name)}>
        <div class="flex justify-between">
        <span><%= title %></span>
          <%= if assigns[:table][:order_by] == name do %>
            <%= render SnownixWeb.IconsView, "sort.svg", %{asc: assigns[:table][:order] == :asc} %>
          <% end %>
        </div>
      </th>
    """
  end

  def render_checkbox(assigns, item) do
    ~H"""
    <div class="big__checkbox" >
        <input type="checkbox" checked={item.selected}>
        <label ></label>
    </div>
    """
  end
end
