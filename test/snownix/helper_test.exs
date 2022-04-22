defmodule Snownix.HelperTest do
  use Snownix.DataCase, async: true

  import Snownix.Helper

  describe "generate_slug/1" do
    test "simple title slug generatin" do
      assert generate_slug(%{title: "This is a simple slug 123"}) ==
               %{slug: "this-is-a-simple-slug-123"}
    end

    test "no field title" do
      assert generate_slug(%{}) == %{}
    end
  end
end
