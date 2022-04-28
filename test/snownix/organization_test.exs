defmodule Snownix.OrganizationTest do
  use Snownix.DataCase

  alias Snownix.Organization

  describe "projects" do
    alias Snownix.Organization.Project

    import Snownix.OrganizationFixtures

    @invalid_attrs %{
      city: nil,
      country: nil,
      email: nil,
      name: nil,
      phone: nil,
      zip: nil,
      street: nil,
      vat: nil
    }

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Organization.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Organization.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        city: "some city",
        country: "some country",
        email: "some email",
        name: "some name",
        phone: "some phone",
        zip: "some zip",
        street: "some street",
        vat: "some vat"
      }

      assert {:ok, %Project{} = project} = Organization.create_project(valid_attrs)
      assert project.city == "some city"
      assert project.country == "some country"
      assert project.email == "some email"
      assert project.name == "some name"
      assert project.phone == "some phone"
      assert project.zip == "some zip"
      assert project.street == "some street"
      assert project.vat == "some vat"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        city: "some updated city",
        country: "some updated country",
        email: "some updated email",
        name: "some updated name",
        phone: "some updated phone",
        zip: "some updated zip",
        street: "some updated street",
        vat: "some updated vat"
      }

      assert {:ok, %Project{} = project} = Organization.update_project(project, update_attrs)
      assert project.city == "some updated city"
      assert project.country == "some updated country"
      assert project.email == "some updated email"
      assert project.name == "some updated name"
      assert project.phone == "some updated phone"
      assert project.zip == "some updated zip"
      assert project.street == "some updated street"
      assert project.vat == "some updated vat"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_project(project, @invalid_attrs)
      assert project == Organization.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Organization.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Organization.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Organization.change_project(project)
    end
  end
end
