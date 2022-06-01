defmodule Snownix.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Customers` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    {:ok, address} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        currency: "some currency",
        fax: "some fax",
        phone: "some phone",
        state: "some state",
        street: "some street",
        street_2: "some street_2",
        zip: "some zip"
      })
      |> Snownix.Customers.create_address()

    address
  end
end
