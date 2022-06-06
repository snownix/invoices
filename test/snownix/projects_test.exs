defmodule Snownix.ProjectsTest do
  use Snownix.DataCase

  alias Snownix.Projects

  describe "activities" do
    alias Snownix.Projects.Activity

    import Snownix.ProjectsFixtures

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

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Projects.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Projects.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      valid_attrs = %{
        from: "some from",
        level: "some level",
        link: "some link",
        note: "some note",
        target_id: "7488a646-e31f-11e4-aace-600308960662",
        title: "some title",
        to: "some to",
        type: "some type"
      }

      assert {:ok, %Activity{} = activity} = Projects.create_activity(valid_attrs)
      assert activity.from == "some from"
      assert activity.level == "some level"
      assert activity.link == "some link"
      assert activity.note == "some note"
      assert activity.target_id == "7488a646-e31f-11e4-aace-600308960662"
      assert activity.title == "some title"
      assert activity.to == "some to"
      assert activity.type == "some type"
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()

      update_attrs = %{
        from: "some updated from",
        level: "some updated level",
        link: "some updated link",
        note: "some updated note",
        target_id: "7488a646-e31f-11e4-aace-600308960668",
        title: "some updated title",
        to: "some updated to",
        type: "some updated type"
      }

      assert {:ok, %Activity{} = activity} = Projects.update_activity(activity, update_attrs)
      assert activity.from == "some updated from"
      assert activity.level == "some updated level"
      assert activity.link == "some updated link"
      assert activity.note == "some updated note"
      assert activity.target_id == "7488a646-e31f-11e4-aace-600308960668"
      assert activity.title == "some updated title"
      assert activity.to == "some updated to"
      assert activity.type == "some updated type"
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_activity(activity, @invalid_attrs)
      assert activity == Projects.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Projects.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Projects.change_activity(activity)
    end
  end
end
