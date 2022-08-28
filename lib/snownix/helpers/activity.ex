defmodule Snownix.Helpers.Activity do
  alias Snownix.Projects.Activity
  alias SnownixWeb.Router.Helpers, as: Routes

  def put_links(socket, %Activity{target_id: target_id, type: "Invoice"} = activity) do
    %{activity | link: Routes.org_invoice_index_path(socket, :show, target_id)}
  end

  def put_links(socket, %Activity{target_id: target_id, type: "Product"} = activity) do
    %{activity | link: Routes.org_product_index_path(socket, :show, target_id)}
  end

  def put_links(socket, %Activity{target_id: target_id, type: "Category"} = activity) do
    %{activity | link: Routes.org_category_index_path(socket, :show, target_id)}
  end

  def put_links(socket, %Activity{target_id: target_id, type: "User"} = activity) do
    %{activity | link: Routes.org_customer_index_path(socket, :show, target_id)}
  end

  def put_links(socket, %Activity{} = activity), do: activity
end
