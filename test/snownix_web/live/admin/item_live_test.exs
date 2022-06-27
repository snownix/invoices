defmodule SnownixWeb.Admin.ItemLiveTest do
  use SnownixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snownix.InvoicesFixtures

  @create_attrs %{description: "some description", discount: 42, name: "some name", price: 42, quantity: 42, tax: 42, total: 42, unit_name: "some unit_name"}
  @update_attrs %{description: "some updated description", discount: 43, name: "some updated name", price: 43, quantity: 43, tax: 43, total: 43, unit_name: "some updated unit_name"}
  @invalid_attrs %{description: nil, discount: nil, name: nil, price: nil, quantity: nil, tax: nil, total: nil, unit_name: nil}

  defp create_item(_) do
    item = item_fixture()
    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, Routes.admin_item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert html =~ item.description
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_item_index_path(conn, :index))

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert_patch(index_live, Routes.admin_item_index_path(conn, :new))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_item_index_path(conn, :index))

      assert html =~ "Item created successfully"
      assert html =~ "some description"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.admin_item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(index_live, Routes.admin_item_index_path(conn, :edit, item))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_item_index_path(conn, :index))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.admin_item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, Routes.admin_item_show_path(conn, :show, item))

      assert html =~ "Show Item"
      assert html =~ item.description
    end

    test "updates item within modal", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, Routes.admin_item_show_path(conn, :show, item))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(show_live, Routes.admin_item_show_path(conn, :edit, item))

      assert show_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_item_show_path(conn, :show, item))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated description"
    end
  end
end
