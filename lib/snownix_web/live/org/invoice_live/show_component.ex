defmodule SnownixWeb.Org.InvoiceLive.ShowComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2 p-0">
        <%= if @invoice.customer do %>
        <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
          <h3>Customer</h3>
        </div>
        <div class="_invoice rounded-md space-y-2 px-2 py-4">
          <%= live_patch to: Routes.org_customer_index_path(@socket, :show, @invoice.customer.id), class: "flex items-center space-x-2" do %>
            <%= render_user_avatar(assigns, @invoice.customer, "w-12 h-12") %>
            <div class="flex flex-col">
              <span class="font-semibold"><%= @invoice.customer.name %></span>
              <span class="text-sm"><%=  @invoice.customer.contact_name %></span>
            </div>
          <% end %>
        </div>
      <% end %>

      <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
          <h3>Information</h3>
      </div>
      <div class="_invoice rounded-md space-y-2 p-4">
          <div class="flex justify-between">
              <div>
                <h3 class="font-bold"><%= @invoice.title || @invoice.invoice_number %></h3>
                <h5>Date : <%= @invoice.from_date %></h5>
                <h5>Due : <%= @invoice.due_date %></h5>
              </div>
              <div class="flex flex-col">
                <div class="flex justify-between space-x-4"><span>Total</span><span class="justify-end"><%= money_format(@invoice.total, @invoice.currency) %></span></div>
                <div class="flex justify-between space-x-4"><small>Subtotal</small><span><%= money_format(@invoice.sub_total, @invoice.currency) %></span></div>
                <div class="flex justify-between space-x-4"><small>Tax</small> <span><%= @invoice.tax_per_item %></span></div>
              </div>
          </div>
          <div>
            <p><%= @invoice.note %></p>
          </div>
          <div class="border-t py-4 !mt-4">
            <label><%= gettext "Creation Date" %>: </label><%= @invoice.inserted_at %>
          </div>
      </div>
    </section>
    """
  end
end
