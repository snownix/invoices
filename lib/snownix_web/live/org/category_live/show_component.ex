defmodule SnownixWeb.Org.CategoryLive.ShowComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2">
    <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
        <h3>Information</h3>
    </div>
    <div class="_category rounded-md space-y-1">
        <div>
            <label><%= gettext "Name" %></label>
            <%= @category.name %>
        </div>
        <div><label><%= gettext "Creation Date" %></label><%= @category.inserted_at %></div>
    </div>
    </section>
    """
  end
end
