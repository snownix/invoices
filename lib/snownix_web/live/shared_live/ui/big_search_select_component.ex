defmodule SnownixWeb.SharedLive.UI.BigSearchSelectComponent do
  use SnownixWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:items, [])
      |> assign(assigns)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="form__group">

      <div id={@id} phx-target={@parent} phx-hook="SearchSelect" class="w-full relative">
        <%= label @form, @field %>

        <div class="flex relative">
          <%= hidden_input @form, @field, value: current_value(@selected_item) %>
          <input class={item_input_class(@selected_item)} phx-change="ignore" placeholder={input_placeholder(@type, @selected_item)} type="text" />
          <button type="button" class="toggle__btn absolute top-3 right-3 p-0 border-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4m0 6l-4 4-4-4" />
            </svg>
          </button>
        </div>

        <%= error_tag @form, @field %>

        <div class="dropdown__content z-20 absolute h-96 max-h-[90vh] md:max-h-[30vh]  -bottom-1 left-0 translate-y-full mt-2 w-full max-h-40 border rounded bg-white" style="display: none;">
          <%= if @items != [] do %>
            <ul class="block py-2 overflow-y-scroll h-full">

              <%= for {id, name} <- @items do %>
                <li>
                  <button
                    type="button"
                    phx-click="search-select-item"
                    phx-target={@parent}
                    phx-value-type={@type}
                    phx-value-name={name}
                    phx-value-id={id}
                    class={item_class(id, @selected_item)}>
                    <span><%= name %></span>
                  </button>
                </li>
              <% end %>
            </ul>

          <% else %>
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
    "search__select__item__active"
  end

  def item_class(_, _) do
    "search__select__item"
  end

  def input_placeholder(_type, {_item_id, item_name}), do: item_name

  def input_placeholder(type, nil), do: "Select a #{type}"

  def item_input_class(nil), do: "search__input"

  def item_input_class(_), do: "search__input placeholder:text-black"
end
