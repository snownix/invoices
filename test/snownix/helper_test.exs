defmodule Snownix.HelperTest do
  use Snownix.DataCase, async: true

  alias Snownix.Products.Product
  alias Snownix.Helpers

  test "cast_float_to_int/2" do
    assert %Product{price: 14050} =
             %Product{}
             |> Ecto.Changeset.change(%{price_float: 140.50})
             |> Helpers.Changeset.cast_float_to_int(price_float: :price)
             |> Ecto.Changeset.apply_changes()

    assert %Product{price: 205} =
             %Product{}
             |> Ecto.Changeset.change(%{price_float: 2.05})
             |> Helpers.Changeset.cast_float_to_int(price_float: :price)
             |> Ecto.Changeset.apply_changes()
  end

  test "cast_float_to_int/3" do
    assert %Product{price: 15040} =
             %Product{}
             |> Ecto.Changeset.change(%{price_float: 150.40})
             |> Helpers.Changeset.cast_float_to_int(:price_float, :price)
             |> Ecto.Changeset.apply_changes()
  end
end
