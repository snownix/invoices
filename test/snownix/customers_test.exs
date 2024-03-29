defmodule Snownix.CustomersTest do
  use Snownix.DataCase

  alias Snownix.Customers

  describe "addresses" do
    alias Snownix.Customers.Address

    import Snownix.CustomersFixtures

    @invalid_attrs %{
      city: nil,
      country: nil,
      currency: nil,
      fax: nil,
      phone: nil,
      state: nil,
      street: nil,
      street_2: nil,
      zip: nil
    }

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Customers.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Customers.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      valid_attrs = %{
        city: "some city",
        country: "MA",
        currency: "MAD",
        fax: "555-000-0000",
        phone: "0600000000",
        state: "some state",
        street: "some street",
        street_2: "some street_2",
        zip: "some zip"
      }

      assert {:ok, %Address{} = address} = Customers.create_address(valid_attrs)
      assert address.city == "some city"
      assert address.country == "MA"
      assert address.currency == "MAD"
      assert address.fax == "555-000-0000"
      assert address.phone == "0600000000"
      assert address.state == "some state"
      assert address.street == "some street"
      assert address.street_2 == "some street_2"
      assert address.zip == "some zip"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()

      update_attrs = %{
        city: "some updated city",
        country: "FR",
        currency: "USD",
        fax: "555-123-4567",
        phone: "0699999999",
        state: "some updated state",
        street: "some updated street",
        street_2: "some updated street_2",
        zip: "some updated zip"
      }

      assert {:ok, %Address{} = address} = Customers.update_address(address, update_attrs)
      assert address.city == "some updated city"
      assert address.country == "FR"
      assert address.currency == "USD"
      assert address.fax == "555-123-4567"
      assert address.phone == "0699999999"
      assert address.state == "some updated state"
      assert address.street == "some updated street"
      assert address.street_2 == "some updated street_2"
      assert address.zip == "some updated zip"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_address(address, @invalid_attrs)
      assert address == Customers.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Customers.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Customers.change_address(address)
    end
  end
end
