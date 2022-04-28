defmodule SnownixWeb.TaxLiveTest do
  use SnownixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snownix.ProjectFixtures

  @create_attrs %{compound_tax: true, description: "some description", name: "some name", percent: 42}
  @update_attrs %{compound_tax: false, description: "some updated description", name: "some updated name", percent: 43}
  @invalid_attrs %{compound_tax: false, description: nil, name: nil, percent: nil}

  defp create_tax(_) do
    tax = tax_fixture()
    %{tax: tax}
  end

  describe "Index" do
    setup [:create_tax]

    test "lists all taxs", %{conn: conn, tax: tax} do
      {:ok, _index_live, html} = live(conn, Routes.tax_index_path(conn, :index))

      assert html =~ "Listing Taxs"
      assert html =~ tax.description
    end

    test "saves new tax", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.tax_index_path(conn, :index))

      assert index_live |> element("a", "New Tax") |> render_click() =~
               "New Tax"

      assert_patch(index_live, Routes.tax_index_path(conn, :new))

      assert index_live
             |> form("#tax-form", tax: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tax-form", tax: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tax_index_path(conn, :index))

      assert html =~ "Tax created successfully"
      assert html =~ "some description"
    end

    test "updates tax in listing", %{conn: conn, tax: tax} do
      {:ok, index_live, _html} = live(conn, Routes.tax_index_path(conn, :index))

      assert index_live |> element("#tax-#{tax.id} a", "Edit") |> render_click() =~
               "Edit Tax"

      assert_patch(index_live, Routes.tax_index_path(conn, :edit, tax))

      assert index_live
             |> form("#tax-form", tax: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#tax-form", tax: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tax_index_path(conn, :index))

      assert html =~ "Tax updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes tax in listing", %{conn: conn, tax: tax} do
      {:ok, index_live, _html} = live(conn, Routes.tax_index_path(conn, :index))

      assert index_live |> element("#tax-#{tax.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tax-#{tax.id}")
    end
  end

  describe "Show" do
    setup [:create_tax]

    test "displays tax", %{conn: conn, tax: tax} do
      {:ok, _show_live, html} = live(conn, Routes.tax_show_path(conn, :show, tax))

      assert html =~ "Show Tax"
      assert html =~ tax.description
    end

    test "updates tax within modal", %{conn: conn, tax: tax} do
      {:ok, show_live, _html} = live(conn, Routes.tax_show_path(conn, :show, tax))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tax"

      assert_patch(show_live, Routes.tax_show_path(conn, :edit, tax))

      assert show_live
             |> form("#tax-form", tax: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#tax-form", tax: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.tax_show_path(conn, :show, tax))

      assert html =~ "Tax updated successfully"
      assert html =~ "some updated description"
    end
  end
end
