defmodule SnownixWeb.Org.CustomerLive.Index do
  use SnownixWeb, :live_dashboard
  import Snownix.Helpers.TablePub

  alias Snownix.Pagination

  alias Snownix.Customers
  alias Snownix.Customers.User

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Snownix.Customers.subscribe(socket.assigns.project.id)

    {:ok,
     socket
     |> assign(:table, %{
       filters: [],
       page: 1,
       limit: 20,
       order: :desc,
       order_by: :inserted_at
     })
     |> fetch()}
  end

  @impl true
  def handle_info({Customers, [:customer, type], customer}, socket) do
    handle_table_pub(
      __MODULE__,
      socket,
      :customers,
      :customer,
      {Customers, [:customer, type], customer}
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     case params do
       %{"id" => id} ->
         customer = customer_user(id)

         if connected?(socket),
           do: Snownix.Customers.subscribe(socket.assigns.project.id, customer.id)

         socket
         |> assign(:customer, customer)

       _ ->
         socket
     end
     |> apply_action(socket.assigns.live_action)}
  end

  @impl true
  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, socket |> push_patch(to: Routes.org_customer_index_path(socket, :show, id))}
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

  def handle_event("period", %{"start" => st, "end" => en}, socket) do
    try do
      pstart = Timex.parse!(st, "{ISO:Extended}")
      pend = Timex.parse!(en, "{ISO:Extended}")

      {:noreply,
       socket
       |> assign_table_filter(
         :period,
         Timex.format!(pstart, "{YYYY}-{0M}-{D}"),
         Timex.format!(pend, "{YYYY}-{0M}-{D}")
       )
       |> fetch()}
    catch
      _ -> {:noreply, socket}
    end
  end

  def handle_event("order", %{"order" => order}, socket) do
    {:noreply, socket |> assign_table_order(order) |> fetch()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = Customers.delete_user(customer_user(id))

    {:noreply, fetch(socket)}
  end

  def handle_event("delete-filter", %{"index" => index}, socket) do
    {:noreply, socket |> delete_filter_by_index(index)}
  end

  defp apply_action(socket, :edit) do
    socket
    |> assign(:page_title, "Edit Customer")
  end

  defp apply_action(socket, :new) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, %User{})
  end

  defp apply_action(socket, :show) do
    socket
    |> assign(:page_title, socket.assigns.customer.name)
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:customer, nil)
    |> assign(:page_title, "Listing Customers")
  end

  def fetch(socket) do
    socket |> list_customer_users()
  end

  def push_index(socket) do
    socket |> push_patch(to: Routes.org_customer_index_path(socket, :index))
  end

  defp customer_user(id) do
    Customers.get_user!(id)
  end

  defp list_customer_users(socket) do
    %{project: project, table: %{page: page, limit: limit, order: order, order_by: order_by}} =
      socket.assigns

    pagination =
      Customers.list_customer_users(project.id, order_by: order_by, order: order)
      |> Pagination.page(page, per_page: limit)

    pagination = %{
      pagination
      | items: pagination.items
    }

    socket
    |> assign(:pagination, pagination)
    |> assign(:customers, pagination.items)
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

    case order in Customers.User.__schema__(:fields) do
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

  defp assign_table_filter(socket, :period, st, en) do
    table = socket.assigns.table

    filters = [
      [:period, st, en]
      | table.filters
    ]

    IO.inspect(filters)
    socket |> assign(:table, %{table | filters: filters})
  end

  defp order_by_toggle(socket) do
    if socket.assigns.table.order == :asc do
      :desc
    else
      :asc
    end
  end

  defp delete_filter_by_index(socket, index) do
    index = String.to_integer(index)
    table = socket.assigns.table

    filters =
      table.filters
      |> Enum.with_index()
      |> Enum.reject(fn {_, i} -> i == index end)
      |> Enum.map(fn {item, _} -> item end)

    socket
    |> assign(:table, %{
      table
      | filters: filters
    })
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

  def render_filter(assigns, :period, [_, st, en], index) do
    ~H"""
        <a class="btn !p-2 !text-xs !rounded-none m-1" id={"period" <> Integer.to_string(index)}>
          <span><%= st %> - <%= en %></span>
          <span class="p-x hover:text-red-500" phx-click="delete-filter" phx-value-index={index}>
            X
          </span>
        </a>
    """
  end
end
