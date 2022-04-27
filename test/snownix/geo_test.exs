defmodule Snownix.GeoTest do
  use Snownix.DataCase, async: true

  import Snownix.Geo

  describe "geo" do
    test "countries list" do
      assert Enum.count(countries()) == 250
    end
  end
end
