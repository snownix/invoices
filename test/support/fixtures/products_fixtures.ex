defmodule Snownix.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Products` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Snownix.Products.create_category()

    category
  end

  @doc """
  Generate a unit.
  """
  def unit_fixture(attrs \\ %{}) do
    {:ok, unit} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Snownix.Products.create_unit()

    unit
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        currency: "some currency",
        description: "some description",
        name: "some name",
        price: 120.5,
        tax_per_item: 120.5
      })
      |> Snownix.Products.create_product()

    product
  end
end
