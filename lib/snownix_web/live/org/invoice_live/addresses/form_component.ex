defmodule SnownixWeb.Org.InvoiceLive.Addresses.FormComponent do
  use SnownixWeb, :live_component

  @impl true
  def update(
        %{
          form: _form,
          name: _name,
          parent: _parent,
          field_name: _field_name,
          selected_item: _selected_item,
          addresses: _addresses
        } = assigns,
        socket
      ) do
    {:ok, socket |> assign(assigns)}
  end

  def countries_options() do
    Snownix.Geo.countries_options()
  end
end
