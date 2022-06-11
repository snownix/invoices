defmodule SnownixWeb.Org.InvoiceLive.ShowComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2 p-0">
    <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
        <h3>Information</h3>
    </div>
    <div class="_invoice rounded-md space-y-2 p-4">
        <div class="flex justify-between">
            <h3 class="font-bold"><%= @invoice.name %></h3>
            <p class="flex flex-col font-bold">
              <span><%= money_format(@invoice) %></span>
              <small>Tax: <%= @invoice.tax_per_item %></small>
            </p>
        </div>
        <div>
          <p><%= @invoice.description %></p>
        </div>
        <div class="border-t py-4">
          <label><%= gettext "Creation Date" %>: </label><%= @invoice.inserted_at %>
        </div>
    </div>
    </section>
    """
  end
end
