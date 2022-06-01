defmodule SnownixWeb.Org.CustomerLive.AddressesComponent do
  use SnownixWeb, :live_component
  import Snownix.Helpers.TablePub

  alias Snownix.Customers

  @impl true
  def render(assigns) do
    ~H"""
    <section class="_addresses space-y-2">
        <div class="flex justify-between py-2 px-4 rounded bg-gray-100 font-medium text-dark">
            <h3>Addresses</h3>
            <button class="rounded p-1"><%= render SnownixWeb.IconsView, "plus.svg",  %{size: 16} %></button>
        </div>
        <div class="_list rounded-md space-y-1">
        <%= for address <- @addresses do %>
            <div class={"flex w-full p-4 bg-gray-50 rounded space-x-4 relative "<> (address.default && "!bg-primary !bg-opacity-10" || "")}>
                <div class="flex flex-col p-2">
                      <img class="rounded object-cover w-6 h-5"  src={"https://flagicons.lipis.dev/flags/4x3/#{String.downcase(address.country)}.svg"}>
                </div>
                <div cass="w-full">
                      <p><%= address.city %>,
                      <%= address.street %></p>
                      <p><%= address.street_2 %></p>
                </div>

                <div class="absolute top-4 right-4 flex space-x-2">
                    <a href="#" phx-click="delete" phx-value-id={address.id} phx-target={@myself} class="bg-red-500 bg-opacity-60 text-light px-1 py-1">
                      <%= render SnownixWeb.IconsView, "delete.svg", %{size: 18} %>
                    </a>

                    <%= if address.default do %>
                        <div class="bg-primary bg-opacity-60 text-light px-2 py-1 "><%= gettext "Default" %></div>
                    <% end %>
                </div>
            </div>
        <% end %>
        <%= if false do %>
            <div>
            <.form
            let={f}
            for={@changeset}
            id="address-form"
            class="space-y-2"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save">

                <div class="form__group">
                <%= label f, :name %>
                <%= text_input f, :name %>
                <%= error_tag f, :name %>
                </div>

                <div class="form__group">
                <%= label f, :contact_name %>
                <%= text_input f, :contact_name %>
                <%= error_tag f, :contact_name %>
                </div>
                <div class="form__group">
                <%= label f, :phone %>
                <%= text_input f, :phone %>
                <%= error_tag f, :phone %>
                </div>
                <div class="form__group">
                <%= label f, :email %>
                <%= text_input f, :email %>
                <%= error_tag f, :email %>
                </div>
                <div class="form__group">
                <%= label f, :website %>
                <%= text_input f, :website %>
                <%= error_tag f, :website %>
                </div>
                <div class="form__group">
                <%= label f, :currency %>
                <%= text_input f, :currency %>
                <%= error_tag f, :currency %>
                </div>
            <div>
                <%= submit "Save", phx_disable_with: "Saving...", class: "primary" %>
            </div>
            </.form>

            </div>
        <% end %>
        </div>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    IO.inspect([assigns.project.id, assigns.customer.id])

    if connected?(socket),
      do: Snownix.Customers.subscribe(assigns.project.id, assigns.customer.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:addresses, assigns.customer.addresses)
     |> assign(:changeset, Customers.change_address(%Customers.Address{}))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Customers.delete_address(get_address(id)) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:norpely, socket |> put_changeset_errors(changeset)}
    end
  end

  def handle_info({Customers, [:address, type], address}, socket) do
    IO.inspect(address, label: "address ")

    handle_table_pub(
      __MODULE__,
      socket,
      :addresses,
      :address,
      {Customers, [:address, type], address}
    )
  end

  defp get_address(id) do
    Customers.get_address!(id)
  end
end
