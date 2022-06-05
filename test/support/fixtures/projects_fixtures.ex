defmodule Snownix.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Projects` context.
  """

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        from: "some from",
        level: "some level",
        link: "some link",
        note: "some note",
        target_id: "7488a646-e31f-11e4-aace-600308960662",
        title: "some title",
        to: "some to",
        type: "some type"
      })
      |> Snownix.Projects.create_activity()

    activity
  end
end
