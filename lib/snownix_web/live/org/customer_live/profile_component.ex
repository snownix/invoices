defmodule SnownixWeb.Org.CustomerLive.ProfileComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2">
    <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
        <h3>Profile</h3>
    </div>
    <div class="_customer rounded-md space-y-1">
        <div>
            <label><%= gettext "Name" %></label>
            <%= @customer.name %>
        </div>
        <div><label><%= gettext "Contact Name" %></label><%= @customer.contact_name %></div>
        <div><label><%= gettext "Email" %></label><%= @customer.email %></div>
        <div><label><%= gettext "Phone" %></label><%= @customer.phone %></div>
        <div><label><%= gettext "Website" %></label><%= @customer.website %></div>
        <div><label><%= gettext "Portal Access" %></label><%= @customer.portal && "Yes" || "No" %></div>
    </div>
    </section>
    """
  end
end
