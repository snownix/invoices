defmodule Snownix.InvoicesTest do
  use Snownix.DataCase

  alias Snownix.Invoices

  describe "invoices" do
    alias Snownix.Invoices.Invoice

    import Snownix.InvoicesFixtures

    @invalid_attrs %{allow_edit: nil, currency: nil, discount: nil, discount_per_item: nil, discount_type: nil, discount_val: nil, due_amount: nil, due_date: nil, from_date: nil, invoice_number: nil, note: nil, paid_status: nil, reference_number: nil, sent_email: nil, sent_sms: nil, sequence_number: nil, status: nil, sub_total: nil, tax: nil, tax_per_item: nil, to_date: nil, total: nil, viewed: nil}

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{allow_edit: true, currency: "some currency", discount: 42, discount_per_item: true, discount_type: "some discount_type", discount_val: 42, due_amount: 42, due_date: ~N[2022-06-04 14:27:00], from_date: ~N[2022-06-04 14:27:00], invoice_number: "some invoice_number", note: "some note", paid_status: "some paid_status", reference_number: "some reference_number", sent_email: true, sent_sms: true, sequence_number: 42, status: "some status", sub_total: 42, tax: 42, tax_per_item: true, to_date: ~N[2022-06-04 14:27:00], total: 42, viewed: 42}

      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(valid_attrs)
      assert invoice.allow_edit == true
      assert invoice.currency == "some currency"
      assert invoice.discount == 42
      assert invoice.discount_per_item == true
      assert invoice.discount_type == "some discount_type"
      assert invoice.discount_val == 42
      assert invoice.due_amount == 42
      assert invoice.due_date == ~N[2022-06-04 14:27:00]
      assert invoice.from_date == ~N[2022-06-04 14:27:00]
      assert invoice.invoice_number == "some invoice_number"
      assert invoice.note == "some note"
      assert invoice.paid_status == "some paid_status"
      assert invoice.reference_number == "some reference_number"
      assert invoice.sent_email == true
      assert invoice.sent_sms == true
      assert invoice.sequence_number == 42
      assert invoice.status == "some status"
      assert invoice.sub_total == 42
      assert invoice.tax == 42
      assert invoice.tax_per_item == true
      assert invoice.to_date == ~N[2022-06-04 14:27:00]
      assert invoice.total == 42
      assert invoice.viewed == 42
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      update_attrs = %{allow_edit: false, currency: "some updated currency", discount: 43, discount_per_item: false, discount_type: "some updated discount_type", discount_val: 43, due_amount: 43, due_date: ~N[2022-06-05 14:27:00], from_date: ~N[2022-06-05 14:27:00], invoice_number: "some updated invoice_number", note: "some updated note", paid_status: "some updated paid_status", reference_number: "some updated reference_number", sent_email: false, sent_sms: false, sequence_number: 43, status: "some updated status", sub_total: 43, tax: 43, tax_per_item: false, to_date: ~N[2022-06-05 14:27:00], total: 43, viewed: 43}

      assert {:ok, %Invoice{} = invoice} = Invoices.update_invoice(invoice, update_attrs)
      assert invoice.allow_edit == false
      assert invoice.currency == "some updated currency"
      assert invoice.discount == 43
      assert invoice.discount_per_item == false
      assert invoice.discount_type == "some updated discount_type"
      assert invoice.discount_val == 43
      assert invoice.due_amount == 43
      assert invoice.due_date == ~N[2022-06-05 14:27:00]
      assert invoice.from_date == ~N[2022-06-05 14:27:00]
      assert invoice.invoice_number == "some updated invoice_number"
      assert invoice.note == "some updated note"
      assert invoice.paid_status == "some updated paid_status"
      assert invoice.reference_number == "some updated reference_number"
      assert invoice.sent_email == false
      assert invoice.sent_sms == false
      assert invoice.sequence_number == 43
      assert invoice.status == "some updated status"
      assert invoice.sub_total == 43
      assert invoice.tax == 43
      assert invoice.tax_per_item == false
      assert invoice.to_date == ~N[2022-06-05 14:27:00]
      assert invoice.total == 43
      assert invoice.viewed == 43
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
end
