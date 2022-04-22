defmodule SnownixWeb.ErrorViewTest do
  use SnownixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(SnownixWeb.ErrorView, "404.html", []) =~ "wrong address"
  end

  test "renders 500.html" do
    assert render_to_string(SnownixWeb.ErrorView, "500.html", []) =~ "crashed"
  end
end
