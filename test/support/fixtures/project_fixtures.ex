defmodule Snownix.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Projects` context.
  """

  @doc """
  Generate a tax.
  """
  def tax_fixture(attrs \\ %{}) do
    {:ok, tax} =
      attrs
      |> Enum.into(%{
        compound_tax: true,
        description: "some description",
        name: "some name",
        percent: 42
      })
      |> Snownix.Projects.create_tax()

    tax
  end
end
