defmodule SnownixWeb.Org.InvoiceLive.Addresses.FormComponent do
  use SnownixWeb, :live_component

  @impl true
  def update(%{form: form, name: name, field_name: field_name} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(name: name)
     |> assign(form: form)
     |> assign(field_name: field_name)}
  end

  def countries_options() do
    Snownix.Geo.countries_options()
  end
end
