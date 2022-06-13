defmodule SnownixWeb.SharedLive.UI.DetailsComponent do
  use SnownixWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:open, false)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @open do %>
        <%= live_patch to: @prev do %>
        <div class="fixed z-30 inset-0 w-full h-full bg-dark bg-opacity-20"></div>
        <% end %>
        <section class={"fixed overflow-y-auto z-40 p-4 m-0 bg-white border-l w-full md:w-2/4 xl:w-1/4 h-full top-0 right-0 space-y-2 md:space-y-6 #{assigns[:class]}"}>
            <div class="_header flex justify-between items-center space-x-4">
                <%= live_patch to: @prev, class: "btn light !p-1" do %>
                  <%= render SnownixWeb.IconsView, "arrow_prev.svg", %{} %>
                <% end %>
                <h3 class="flex-grow"><%= render_slot(@title) %></h3>
            </div>
            <div class="_body space-y-4">
              <%= render_slot(@body) %>
            </div>
        </section>
      <% end %>
    </div>
    """
  end
end
