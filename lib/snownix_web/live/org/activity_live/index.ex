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
       limit: 100,
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
    |> assign(:activities, group_activities(pagination.items))
  end

  defp group_activities(items) do
    items
    |> Enum.group_by(fn e -> Timex.to_date(e.inserted_at) end, & &1)
    |> Enum.map(fn {date, items} ->
      {date,
       Enum.reduce(items, %{last: nil, values: []}, fn e, acc ->
         %{last: e, values: acc.values ++ [{acc.last && acc.last.inserted_at, e}]}
       end).values}
    end)
    |> Enum.reverse()
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

  def render_activity(socket, assigns, row, last_inserted_at \\ nil) do
    same_prev_time = hour_format(last_inserted_at) === hour_format(row.inserted_at)

    row = Snownix.Helpers.Activity.put_links(socket, row)

    ~H"""
    <div class={"activity__block px-8 " <> (if same_prev_time, do: "", else: "pt-2")} id={"activity-#{row.id}"}>
        <div class="_meta flex items-center w-8 h-8">
          <%= if !same_prev_time do %>
            <div class="_type w-8 h-8 bg-primary text-sm rounded-full flex items-center justify-center text-white uppercase">
              <span><%= (row.action || row.type || "") |> String.slice(0,1) %></span>
            </div>
          <% end %>
        </div>
        <div class="_content flex flex-col">
          <%= if !same_prev_time do %>
            <div class="activity__time">
              <time datetime={row.inserted_at}><%= hour_format(row.inserted_at) %></time>
              <time datetime={row.inserted_at}><%= datetime_format(row.inserted_at) %></time>
            </div>
          <% end %>
          <div class={"activity__icon " <> (if same_prev_time, do: "mt-1", else: "mt-2")}>
                <a class="flex items-center space-x-2">
                  <div class={(if same_prev_time, do: "hidden md:block", else: "")}>
                    <%= render_text_avatar(assigns, row.from) %>
                  </div>
                  <span class="font-semibold"><%= row.from %></span>
                </a>
                <p>
                <span><%= get_emoji(row.action) %></span>

                  <%= for txt <- row.title |> String.split("**") do %>
                    <%= if txt == row.name do %>
                      <%= live_patch txt, to: row.link, class: "font-bold" %>
                    <% else %>
                    <%= txt %>
                    <% end %>
                  <% end %>
                </p>
            </div>

            <%= if row.note do %>
                <div class="_note lg:pl-4 flex">
                    <span class="hidden lg:block text-dark text-opacity-50">
                        <svg class="w-8" viewBox="-4 10 90 100" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-width="6"
                                d="m2.69412,-2.13346c9.09909,113.20112 63.71794,96.63965 92.62963,98.87074"
                                stroke="currentColor" fill="none"></path>
                        </svg>
                    </span>
                    <p class="p-4 lg:px-6 border blrder-gray-500 rounded-lg whitespace-pre-wrap"><%= for txt <- row.note |> String.split("**") do %><%= if txt == row.name do %><strong class="font-bold"><%= txt %></strong><% else %><%= txt %><% end %><% end %></p>
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
