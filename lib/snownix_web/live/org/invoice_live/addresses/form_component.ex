defmodule SnownixWeb.Org.InvoiceLive.Addresses.FormComponent do
  use SnownixWeb, :live_component

  @impl true
  def update(
        %{
          form: _form,
          title: _title,
          parent: _parent,
          field_name: field_name,
          selected_item: _selected_item,
          addresses: _addresses,
          added: added
        } = assigns,
        socket
      ) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(field_name_id: String.to_atom("#{field_name}_id"))}
  end

  def countries_options() do
    Snownix.Geo.countries_options()
  end
end
