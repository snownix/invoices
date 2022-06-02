defmodule SnownixWeb.Org.ProductLive.ShowComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2">
    <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
        <h3>Information</h3>
    </div>
    <div class="_product rounded-md space-y-1">
        <div>
            <label><%= gettext "Name" %></label>
            <%= @product.name %>
        </div>
        <div><label><%= gettext "Creation Date" %></label><%= @product.inserted_at %></div>
    </div>
    </section>
    """
  end
end
