defmodule Snownix.ProjectsTest do
  use Snownix.DataCase

  alias Snownix.Projects

  describe "taxs" do
    alias Snownix.Projects.Tax

    import Snownix.ProjectsFixtures

    @invalid_attrs %{compound_tax: nil, description: nil, name: nil, percent: nil}

    test "list_taxs/0 returns all taxs" do
      tax = tax_fixture()
      assert Projects.list_taxs() == [tax]
    end

    test "get_tax!/1 returns the tax with given id" do
      tax = tax_fixture()
      assert Projects.get_tax!(tax.id) == tax
    end

    test "create_tax/1 with valid data creates a tax" do
      valid_attrs = %{
        compound_tax: true,
        description: "some description",
        name: "some name",
        percent: 42
      }

      assert {:ok, %Tax{} = tax} = Projects.create_tax(valid_attrs)
      assert tax.compound_tax == true
      assert tax.description == "some description"
      assert tax.name == "some name"
      assert tax.percent == 42
    end

    test "create_tax/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_tax(@invalid_attrs)
    end

    test "update_tax/2 with valid data updates the tax" do
      tax = tax_fixture()

      update_attrs = %{
        compound_tax: false,
        description: "some updated description",
        name: "some updated name",
        percent: 43
      }

      assert {:ok, %Tax{} = tax} = Projects.update_tax(tax, update_attrs)
      assert tax.compound_tax == false
      assert tax.description == "some updated description"
      assert tax.name == "some updated name"
      assert tax.percent == 43
    end

    test "update_tax/2 with invalid data returns error changeset" do
      tax = tax_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_tax(tax, @invalid_attrs)
      assert tax == Projects.get_tax!(tax.id)
    end

    test "delete_tax/1 deletes the tax" do
      tax = tax_fixture()
      assert {:ok, %Tax{}} = Projects.delete_tax(tax)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_tax!(tax.id) end
    end

    test "change_tax/1 returns a tax changeset" do
      tax = tax_fixture()
      assert %Ecto.Changeset{} = Projects.change_tax(tax)
    end
  end
end
