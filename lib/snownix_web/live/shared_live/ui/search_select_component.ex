defmodule SnownixWeb.SharedLive.UI.SearchSelectComponent do
  use SnownixWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:filtered_items, assigns.items)

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", input, %{assigns: %{items: items}} = socket) do
    filtered_items =
      items
      |> Enum.filter(fn {name, id} ->
        name
        |> String.downcase()
        |> String.contains?(String.downcase(input))
      end)

    {:noreply, assign(socket, :filtered_items, filtered_items)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="form__group">
      <div id={@id} phx-target={@myself} phx-hook="SearchSelect" class="w-full relative">
        <%= label @form, @field %>
        <div class="flex relative">
          <%= hidden_input @form, @field, value: current_value(@selected_item) %>
          <input class={unit_input_class(@selected_item)} phx-change="ignore" placeholder={unit_placeholder(@selected_item)} type="text" />
          <button type="button" class="toggle-btn absolute top-3 right-3 p-0 border-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4m0 6l-4 4-4-4" />
            </svg>
          </button>
        </div>
        <%= error_tag @form, @field %>
        <div
          class="dropdown-content absolute -bottom-1 left-0 translate-y-full mt-2 w-full max-h-40 border rounded bg-white">
          <%= if @filtered_items != [] do %>
            <ul class="flex flex-col py-2">
              <%= for {id, name} <- @filtered_items do %>
                <li>
                  <button
                    phx-target={@parent}
                    type="button"
                    phx-click="selected-item"
                    phx-value-type={@type}
                    phx-value-name={name}
                    phx-value-id={id}
                    class={item_class(id, @selected_item)}>
                    <span><%= name %></span>
                  </button>
                </li>
              <% end %>
            </ul>
          <%= else %>
            <div class="flex h-40 items-center justify-center">
              <span class="text-sm">No items found</span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def current_value({id, _}), do: id
  def current_value(_), do: nil

  def item_class(id, {selected_id, _}) when id == selected_id do
    "bg-indigo-600 text-white w-full px-4 py-2 border-0 rounded-none flex justify-start"
  end

  def item_class(_, _) do
    "hover:bg-indigo-100 w-full px-4 py-2 border-0 rounded-none flex justify-start"
  end

  def unit_placeholder({_unit_id, unit_name}), do: unit_name

  def unit_placeholder(nil), do: "Select a unit"

  def unit_input_class(nil), do: "search-input"

  def unit_input_class(_), do: "search-input placeholder:text-black"
end
