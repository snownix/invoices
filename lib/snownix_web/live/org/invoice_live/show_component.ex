defmodule SnownixWeb.Org.InvoiceLive.ShowComponent do
  use SnownixWeb, :live_component

  def render_address(assigns, label, address) do
    ~H"""
    <div class="flex flex-col">
      <h4 class="font-semibold"><%= label %></h4>
      <ul>
        <li  class="flex space-x-2 items-center">
         <img src={"https://flagicons.lipis.dev/flags/4x3/" <> String.downcase(address.country) <> ".svg"} class="w-6 h-4 rounded object-cover" />
          <span><%= address.street %>, <%= address.street_2 %></span>
        </li>
        <li>
         <%= address.city %> -  <%= address.state %> <%= address.zip %>
        </li>
      </ul>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <section class="_profile space-y-2 p-0">
      <%= if @invoice.customer do %>
        <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
            <h3>Customer</h3>
          </div>
          <div class="_invoice flex flex-col md:flex-row justify-between items-start rounded-md space-y-2 px-2 py-4">
            <%= live_patch to: Routes.org_customer_index_path(@socket, :show, @invoice.customer.id), class: "flex items-center space-x-2 w-full" do %>
              <%= render_user_avatar(assigns, @invoice.customer, "w-12 h-12") %>
              <div class="flex flex-col">
                <span class="font-semibold"><%= @invoice.customer.name %></span>
                <span class="text-sm"><%=  @invoice.customer.contact_name %></span>
              </div>
            <% end %>

            <div class="flex flex-row justify-between w-full">
            <%= if @invoice.billing_address_id do %>
              <%= render_address(assigns, "Billing Address", @invoice.billing_address) %>
            <% end %>
            <%= if @invoice.shipping_address_id do %>
              <%= render_address(assigns, "Shipping Address", @invoice.shipping_address) %>
            <% end %>
            </div>
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
                <div class="flex justify-between space-x-4 items-center">
                  <span>Total</span>
                  <span class="justify-end font-bold"><%= money_format(@invoice.total, @invoice.currency) %></span>
                </div>
                <div class="flex justify-between space-x-4 items-center">
                  <small>SubTotal</small>
                  <small class="font-semibold"><%= money_format(@invoice.sub_total, @invoice.currency) %></small>
                </div>
                <div class="flex justify-between space-x-4 items-center">
                  <small>Discount</small>
                  <small class="font-semibold"><%= money_format(@invoice.discount_total, @invoice.currency) %></small>
                </div>
                <div class="flex justify-between space-x-4 items-center">
                  <small>Tax</small>
                  <span class="text-sm"><%= tax_format(@invoice.tax_total) %></span>
                </div>
              </div>
          </div>
          <div>
            <p><%= @invoice.note %></p>
          </div>
      </div>

      <div class="py-2 px-6 rounded bg-gray-100 font-medium text-dark">
        <h3>Items</h3>
      </div>
      <table class="invoices__table__view table-fixed">
        <tbody>
          <%= for item <- @invoice.items do %>
            <tr>
              <td class="w-full">
                <p><%= item.name %></p>
              </td>
              <td class="w-40">
                <div class="flex justify-between">
                  <span><%= item.quantity %></span>
                  <span>x</span>
                  <span><%= money_format(item.price, @invoice.currency) %></span>
                </div>
              </td>
              <%= if @invoice.discount_per_item do %>
                <td class="w-32 text-right">
                  <div class="flex flex-col">
                    -<%= if item.discount_type === "fixed" do %>
                      <%= money_format(item.discount_total, @invoice.currency) %>
                    <% else %>
                      <%= float_format(item.discount) %>%
                    <% end %>
                  </div>
                </td>
              <% end %>
              <td class="w-24 text-right font-semibold"><%= money_format(item.total, @invoice.currency) %></td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <div class="border-t p-4 !mt-4">
        <label><%= gettext "Creation Date" %>: </label><%= @invoice.inserted_at %>
      </div>
    </section>
    """
  end
end
