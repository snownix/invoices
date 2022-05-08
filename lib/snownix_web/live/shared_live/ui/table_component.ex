defmodule SnownixWeb.SharedLive.UI.TableComponent do
  use SnownixWeb, :live_component

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <table class="table-auto">
        <thead>
          <%= render_slot(@thead) %>
        </thead>
        <tbody>
          <%= render_slot(@tbody) %>
        </tbody>
        <tfoot>
          <%= if assigns[:tfoot], do: render_slot(@tfoot), else: "" %>
        </tfoot>
      </table>
    """
  end
end
