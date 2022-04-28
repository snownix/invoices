defmodule Snownix.OrganizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Organization` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        email: "some email",
        name: "some name",
        phone: "some phone",
        zip: "some zip",
        street: "some street",
        vat: "some vat"
      })
      |> Snownix.Organization.create_project()

    project
  end
end
