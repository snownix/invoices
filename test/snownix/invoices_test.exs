defmodule Snownix.InvoicesTest do
  use Snownix.DataCase

  alias Snownix.Invoices

  describe "invoices" do
    alias Snownix.Invoices.Invoice

    import Snownix.InvoicesFixtures

    @invalid_attrs %{
      allow_edit: nil,
      currency: nil,
      discount: nil,
      discount_per_item: nil,
      discount_type: nil,
      discount_val: nil,
      due_amount: nil,
      due_date: nil,
      from_date: nil,
      invoice_number: nil,
      note: nil,
      paid_status: nil,
      reference_number: nil,
      email_sent: nil,
      sms_sent: nil,
      sequence_number: nil,
      status: nil,
      sub_total: nil,
      tax: nil,
      tax_per_item: nil,
      to_date: nil,
      total: nil,
      viewed: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{
        allow_edit: true,
        currency: "MAD",
        discount: 42,
        discount_per_item: true,
        discount_type: "some discount_type",
        discount_val: 42,
        due_amount: 42,
        due_date: ~D[2020-01-01],
        from_date: ~D[2020-01-01],
        invoice_number: "some invoice_number",
        note: "some note",
        paid_status: "some paid_status",
        reference_number: "some reference_number",
        email_sent: true,
        sms_sent: true,
        sequence_number: 42,
        status: "some status",
        sub_total: 42,
        tax: 42,
        tax_per_item: true,
        to_date: ~D[2020-01-01],
        total: 42,
        viewed: true
      }

      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(valid_attrs)
      assert invoice.allow_edit == true
      assert invoice.currency == "MAD"
      assert invoice.discount == 42
      assert invoice.discount_per_item == true
      assert invoice.discount_type == "some discount_type"
      assert invoice.discount_val == 42
      assert invoice.due_amount == 42
      assert invoice.due_date == ~D[2020-01-01]
      assert invoice.from_date == ~D[2020-01-01]
      assert invoice.invoice_number == "some invoice_number"
      assert invoice.note == "some note"
      assert invoice.paid_status == "some paid_status"
      assert invoice.reference_number == "some reference_number"
      assert invoice.email_sent == true
      assert invoice.sms_sent == true
      assert invoice.sequence_number == 42
      assert invoice.status == "some status"
      assert invoice.sub_total == 42
      assert invoice.tax == 42
      assert invoice.tax_per_item == true
      assert invoice.to_date == ~D[2020-01-01]
      assert invoice.total == 42
      assert invoice.viewed == true
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      update_attrs = %{
        allow_edit: false,
        currency: "EUR",
        discount: 43,
        discount_per_item: false,
        discount_type: "some updated discount_type",
        discount_val: 43,
        due_amount: 43,
        due_date: ~D[2020-01-01],
        from_date: ~D[2020-01-01],
        invoice_number: "some updated invoice_number",
        note: "some updated note",
        paid_status: "some updated paid_status",
        reference_number: "some updated reference_number",
        email_sent: false,
        sms_sent: false,
        sequence_number: 43,
        status: "some updated status",
        sub_total: 43,
        tax: 43,
        tax_per_item: false,
        to_date: ~D[2020-01-01],
        total: 43,
        viewed: false
      }

      assert {:ok, %Invoice{} = invoice} = Invoices.update_invoice(invoice, update_attrs)
      assert invoice.allow_edit == false
      assert invoice.currency == "EUR"
      assert invoice.discount == 43
      assert invoice.discount_per_item == false
      assert invoice.discount_type == "some updated discount_type"
      assert invoice.discount_val == 43
      assert invoice.due_amount == 43
      assert invoice.due_date == ~D[2020-01-01]
      assert invoice.from_date == ~D[2020-01-01]
      assert invoice.invoice_number == "some updated invoice_number"
      assert invoice.note == "some updated note"
      assert invoice.paid_status == "some updated paid_status"
      assert invoice.reference_number == "some updated reference_number"
      assert invoice.email_sent == false
      assert invoice.sms_sent == false
      assert invoice.sequence_number == 43
      assert invoice.status == "some updated status"
      assert invoice.sub_total == 43
      assert invoice.tax == 43
      assert invoice.tax_per_item == false
      assert invoice.to_date == ~D[2020-01-01]
      assert invoice.total == 43
      assert invoice.viewed == false
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end

  describe "items" do
    alias Snownix.Invoices.Item

    import Snownix.InvoicesFixtures

    @invalid_attrs %{description: nil, discount: nil, name: nil, price: nil, quantity: nil, tax: nil, total: nil, unit_name: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Invoices.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Invoices.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{description: "some description", discount: 42, name: "some name", price: 42, quantity: 42, tax: 42, total: 42, unit_name: "some unit_name"}

      assert {:ok, %Item{} = item} = Invoices.create_item(valid_attrs)
      assert item.description == "some description"
      assert item.discount == 42
      assert item.name == "some name"
      assert item.price == 42
      assert item.quantity == 42
      assert item.tax == 42
      assert item.total == 42
      assert item.unit_name == "some unit_name"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{description: "some updated description", discount: 43, name: "some updated name", price: 43, quantity: 43, tax: 43, total: 43, unit_name: "some updated unit_name"}

      assert {:ok, %Item{} = item} = Invoices.update_item(item, update_attrs)
      assert item.description == "some updated description"
      assert item.discount == 43
      assert item.name == "some updated name"
      assert item.price == 43
      assert item.quantity == 43
      assert item.tax == 43
      assert item.total == 43
      assert item.unit_name == "some updated unit_name"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoices.update_item(item, @invalid_attrs)
      assert item == Invoices.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Invoices.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Invoices.change_item(item)
    end
  end
end
