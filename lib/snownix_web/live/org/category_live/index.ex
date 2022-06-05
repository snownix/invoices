defmodule SnownixWeb.Org.CategoryLive.Index do
  use SnownixWeb, :live_dashboard
  import Snownix.Helpers.TablePub

  alias Snownix.Pagination

  alias Snownix.Products
  alias Snownix.Products.Category

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Snownix.Products.subscribe(project_id(socket))

    {:ok,
     socket
     |> assign(:table, %{
       filters: [],
       page: 1,
       limit: 20,
       order: :desc,
       order_by: :inserted_at
     })
     |> assign(all_selected: false, selected_items: [])
     |> fetch()}
  end

  @impl true
  def handle_info({Products, [:category, type], result}, socket) do
    handle_table_pub(
      __MODULE__,
      socket,
      :categories,
      :category,
      {Products, [:category, type], result}
    )
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     case params do
       %{"id" => id} ->
         if connected?(socket),
           do: Snownix.Products.subscribe(project_id(socket), id)

         socket |> fetch_one(id)

       _ ->
         socket
     end
     |> apply_action(socket.assigns.live_action)}
  end

  @impl true
  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, socket |> push_patch(to: Routes.org_category_index_path(socket, :show, id))}
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
    %{project: project, current_user: user} = socket.assigns

    {:ok, _} = Products.delete_category(category_id(project.id, id), project, user)

    {:noreply, fetch(socket)}
  end

  def handle_event("delete-selected", _, socket) do
    {:ok, _} = Products.delete_categories(project_id(socket), socket.assigns.selected_items)

    {:noreply, fetch(socket) |> assign(selected_items: [])}
  end

  def handle_event("clone-selected", _, socket) do
    {:ok, %{insert_all: {_, ids}}} =
      Products.clone_categories(project_id(socket), socket.assigns.selected_items)

    {:noreply, fetch(socket) |> assign(selected_items: ids |> Enum.map(& &1.id))}
  end

  def handle_event("delete-filter", %{"index" => index}, socket) do
    {:noreply, socket |> delete_filter_by_index(index)}
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
    |> assign(:page_title, "Edit Category")
  end

  defp apply_action(socket, :new) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :show) do
    socket
    |> assign(:page_title, socket.assigns.category.name)
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:category, nil)
    |> assign(:page_title, "Listing Products")
  end

  def fetch(socket) do
    socket |> list_categories() |> update_selected()
  end

  def fetch_one(socket, id) do
    socket
    |> assign(:category, category_id(project_id(socket), id))
  end

  def push_index(socket) do
    socket |> push_patch(to: Routes.org_category_index_path(socket, :index))
  end

  defp category_id(project_id, id) do
    Products.get_category!(project_id, id)
  end

  defp project_id(%{assigns: %{project: %{id: id}}}) do
    id
  end

  defp list_categories(socket) do
    %{project: project, table: %{page: page, limit: limit, order: order, order_by: order_by}} =
      socket.assigns

    pagination =
      Products.list_categories(project.id, order_by: order_by, order: order)
      |> Pagination.page(page, per_page: limit)

    pagination = %{
      pagination
      | items: pagination.items
    }

    socket
    |> assign(:pagination, pagination)
    |> assign(:categories, pagination.items)
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

    case order in Products.Category.__schema__(:fields) do
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
    %{table: table} = socket.assigns

    filters = [
      [:period, st, en]
      | table.filters
    ]

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

  defp select_item(socket, id) do
    %{
      categories: categories,
      all_selected: all_selected,
      selected_items: selected_items
    } = socket.assigns

    categories =
      categories
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

    selected_ids = Enum.filter(categories, &(&1.selected == true)) |> Enum.map(& &1.id)
    un_selected_ids = Enum.filter(categories, &(&1.selected == false)) |> Enum.map(& &1.id)

    selected_items =
      (selected_items ++ selected_ids)
      |> Enum.uniq()
      |> Enum.reject(&Enum.member?(un_selected_ids, &1))

    socket
    |> assign(
      categories: categories,
      selected_items: selected_items
    )
  end

  defp toggle_select(item) do
    %{item | selected: !item.selected}
  end

  defp update_selected(socket) do
    %{categories: categories, selected_items: selected_items} = socket.assigns

    categories =
      categories
      |> Enum.map(fn item ->
        if Enum.member?(selected_items, item.id) do
          %{item | selected: true}
        else
          item
        end
      end)

    socket
    |> assign(:categories, categories)
    |> assign(
      :all_selected,
      is_nil(Enum.find(categories, &(&1.selected == false))) && Enum.count(categories) > 0
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

  def render_checkbox(assigns, item) do
    ~H"""
    <div class="big__checkbox" >
        <input type="checkbox" checked={item.selected}>
        <label ></label>
    </div>
    """
  end

  def render_filters(assigns) do
    ~H"""
    <%= for {filter, index} <- Enum.with_index(@table.filters) do %>
      <%= render_filter(assigns,Enum.at(filter,0), filter, index) %>
    <% end %>
    """
  end
end
