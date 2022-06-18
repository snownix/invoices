defmodule Snownix.ProductsTest do
  use Snownix.DataCase

  alias Snownix.Products

  describe "categories" do
    alias Snownix.Products.Category

    import Snownix.ProductsFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Products.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Products.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Products.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Products.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_category(category, @invalid_attrs)
      assert category == Products.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Products.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Products.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Products.change_category(category)
    end
  end

  describe "units" do
    alias Snownix.Products.Unit

    import Snownix.ProductsFixtures

    @invalid_attrs %{name: nil}

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Products.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Products.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Unit{} = unit} = Products.create_unit(valid_attrs)
      assert unit.name == "some name"
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Unit{} = unit} = Products.update_unit(unit, update_attrs)
      assert unit.name == "some updated name"
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_unit(unit, @invalid_attrs)
      assert unit == Products.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Products.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Products.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Products.change_unit(unit)
    end
  end

  describe "products" do
    alias Snownix.Products.Product

    import Snownix.ProductsFixtures

    @invalid_attrs %{currency: nil, description: nil, name: nil, price: nil, tax_per_item: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{
        currency: "MAD",
        description: "some description",
        name: "some name",
        price_float: 120.50,
        tax_per_item: true
      }

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.currency == "MAD"
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 12_050
      assert product.tax_per_item == true
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        currency: "USD",
        description: "some updated description",
        name: "some updated name",
        price_float: 457.00,
        tax_per_item: false
      }

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.currency == "USD"
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 45_700
      assert product.tax_per_item == false
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
