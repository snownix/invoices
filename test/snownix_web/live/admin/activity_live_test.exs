defmodule SnownixWeb.Admin.ActivityLiveTest do
  use SnownixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snownix.ProjectsFixtures

  @create_attrs %{
    from: "some from",
    level: "some level",
    link: "some link",
    note: "some note",
    target_id: "7488a646-e31f-11e4-aace-600308960662",
    title: "some title",
    to: "some to",
    type: "some type"
  }
  @update_attrs %{
    from: "some updated from",
    level: "some updated level",
    link: "some updated link",
    note: "some updated note",
    target_id: "7488a646-e31f-11e4-aace-600308960668",
    title: "some updated title",
    to: "some updated to",
    type: "some updated type"
  }
  @invalid_attrs %{
    from: nil,
    level: nil,
    link: nil,
    note: nil,
    target_id: nil,
    title: nil,
    to: nil,
    type: nil
  }

  defp create_activity(_) do
    activity = activity_fixture()
    %{activity: activity}
  end

  describe "Index" do
    setup [:create_activity]

    test "lists all activities", %{conn: conn, activity: activity} do
      {:ok, _index_live, html} = live(conn, Routes.admin_activity_index_path(conn, :index))

      assert html =~ "Listing Activities"
      assert html =~ activity.from
    end

    test "saves new activity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_activity_index_path(conn, :index))

      assert index_live |> element("a", "New Activity") |> render_click() =~
               "New Activity"

      assert_patch(index_live, Routes.admin_activity_index_path(conn, :new))

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#activity-form", activity: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_activity_index_path(conn, :index))

      assert html =~ "Activity created successfully"
      assert html =~ "some from"
    end

    test "updates activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, Routes.admin_activity_index_path(conn, :index))

      assert index_live |> element("#activity-#{activity.id} a", "Edit") |> render_click() =~
               "Edit Activity"

      assert_patch(index_live, Routes.admin_activity_index_path(conn, :edit, activity))

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#activity-form", activity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_activity_index_path(conn, :index))

      assert html =~ "Activity updated successfully"
      assert html =~ "some updated from"
    end

    test "deletes activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, Routes.admin_activity_index_path(conn, :index))

      assert index_live |> element("#activity-#{activity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#activity-#{activity.id}")
    end
  end

  describe "Show" do
    setup [:create_activity]

    test "displays activity", %{conn: conn, activity: activity} do
      {:ok, _show_live, html} = live(conn, Routes.admin_activity_show_path(conn, :show, activity))

      assert html =~ "Show Activity"
      assert html =~ activity.from
    end

    test "updates activity within modal", %{conn: conn, activity: activity} do
      {:ok, show_live, _html} = live(conn, Routes.admin_activity_show_path(conn, :show, activity))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Activity"

      assert_patch(show_live, Routes.admin_activity_show_path(conn, :edit, activity))

      assert show_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#activity-form", activity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_activity_show_path(conn, :show, activity))

      assert html =~ "Activity updated successfully"
      assert html =~ "some updated from"
    end
  end
end
