defmodule SnownixWeb.Admin.GroupLiveTest do
  use SnownixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snownix.InvoicesFixtures

  @create_attrs %{identifier_format: "some identifier_format", left_pad: 42, name: "some name", next_id: 42}
  @update_attrs %{identifier_format: "some updated identifier_format", left_pad: 43, name: "some updated name", next_id: 43}
  @invalid_attrs %{identifier_format: nil, left_pad: nil, name: nil, next_id: nil}

  defp create_group(_) do
    group = group_fixture()
    %{group: group}
  end

  describe "Index" do
    setup [:create_group]

    test "lists all groups", %{conn: conn, group: group} do
      {:ok, _index_live, html} = live(conn, Routes.admin_group_index_path(conn, :index))

      assert html =~ "Listing Groups"
      assert html =~ group.identifier_format
    end

    test "saves new group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_group_index_path(conn, :index))

      assert index_live |> element("a", "New Group") |> render_click() =~
               "New Group"

      assert_patch(index_live, Routes.admin_group_index_path(conn, :new))

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#group-form", group: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_group_index_path(conn, :index))

      assert html =~ "Group created successfully"
      assert html =~ "some identifier_format"
    end

    test "updates group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, Routes.admin_group_index_path(conn, :index))

      assert index_live |> element("#group-#{group.id} a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(index_live, Routes.admin_group_index_path(conn, :edit, group))

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#group-form", group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_group_index_path(conn, :index))

      assert html =~ "Group updated successfully"
      assert html =~ "some updated identifier_format"
    end

    test "deletes group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, Routes.admin_group_index_path(conn, :index))

      assert index_live |> element("#group-#{group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#group-#{group.id}")
    end
  end

  describe "Show" do
    setup [:create_group]

    test "displays group", %{conn: conn, group: group} do
      {:ok, _show_live, html} = live(conn, Routes.admin_group_show_path(conn, :show, group))

      assert html =~ "Show Group"
      assert html =~ group.identifier_format
    end

    test "updates group within modal", %{conn: conn, group: group} do
      {:ok, show_live, _html} = live(conn, Routes.admin_group_show_path(conn, :show, group))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(show_live, Routes.admin_group_show_path(conn, :edit, group))

      assert show_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#group-form", group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_group_show_path(conn, :show, group))

      assert html =~ "Group updated successfully"
      assert html =~ "some updated identifier_format"
    end
  end
end
