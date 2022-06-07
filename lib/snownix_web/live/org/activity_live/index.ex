defmodule SnownixWeb.Org.ActivityLive.Index do
  use SnownixWeb, :live_dashboard
  import Snownix.Helpers.TablePub

  alias Snownix.Pagination

  alias Snownix.Projects

  def mount(_params, _session, socket) do
    if connected?(socket), do: Snownix.Projects.subscribe(socket.assigns.project.id)

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

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_info({Projects, [name, type], result}, socket) do
    case name do
      :activity ->
        handle_table_pub(
          __MODULE__,
          socket,
          :activities,
          :activity,
          {Projects, [:activity, type], result}
        )

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("order", %{"order" => order}, socket) do
    {:noreply, socket |> assign_table_order(order) |> fetch()}
  end

  def handle_event("page", %{"page" => page}, socket) do
    {:noreply, socket |> assign_table_page(page) |> fetch()}
  end

  def push_index(socket) do
    socket
  end

  defp list_activities(socket) do
    %{project: project, table: %{page: page, limit: limit, order: order, order_by: order_by}} =
      socket.assigns

    pagination =
      Projects.list_activities(project.id, order_by: order_by, order: order)
      |> Pagination.page(page, per_page: limit)

    pagination = %{
      pagination
      | items: pagination.items
    }

    socket
    |> assign(:pagination, pagination)
    |> assign(:activities, pagination.items)
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

    case order in Projects.Activity.__schema__(:fields) do
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

  def fetch(socket) do
    socket |> list_activities()
  end

  def render_activity(assigns, row) do
    ~H"""
    <div class="_activity w-full py-2 flex items-start space-x-4">
        <div class="_meta flex items-center space-x-2">
            <div class="_type w-8 h-8 bg-primary text-sm rounded-full flex items-center justify-center text-white">
                <span><%= (row.action || row.type || "") |> String.slice(0,1) %></span>
            </div>
        </div>

        <div class="_content flex flex-col">
            <time phx-hook="TimeAgo" id={row.id} datetime={row.inserted_at}><%= hour_format(row.inserted_at) %></time>
            <div class="_icon mt-2 flex items-center space-x-2 ">
                <a class="flex items-center space-x-2">
                  <%= render_text_avatar(assigns, row.from) %>
                  <span class="font-semibold"><%= row.from %></span>
                </a>
                <p><%= get_emoji(row.action) %>
                  <%= for txt <- row.title |> String.split("**") do %>
                    <%= if txt == row.name do %>
                      <a class="font-bold" href={row.link} target="_blank">
                        <%= txt %>
                      </a>
                    <% else %>
                    <%= txt %>
                    <% end %>
                  <% end %>
                </p>
            </div>

            <%= if row.note do %>
                <div class="_note ml-4 flex">
                    <span class="text-dark text-opacity-50">
                        <svg class="w-8" viewBox="-4 10 90 100" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-width="6"
                                d="m2.69412,-2.13346c9.09909,113.20112 63.71794,96.63965 92.62963,98.87074"
                                stroke="currentColor" fill="none"></path>
                        </svg>
                    </span>
                    <p class="p-4 lg:px-6 border blrder-gray-500 rounded-lg whitespace-pre"><%= for txt <- row.note |> String.split("**") do %><%= if txt == row.name do %><strong class="font-bold"><%= txt %></strong><% else %><%= txt %><% end %><% end %></p>
                </div>
            <% end %>
        </div>
    </div>
    """
  end

  def get_emoji(action) do
    case action do
      "create" -> "➕"
      "delete" -> "🗑️"
      "update" -> "⚠️"
      _ -> ""
    end
  end
end
