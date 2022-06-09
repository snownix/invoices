defmodule SnownixWeb.Admin.InvoiceLiveTest do
  use SnownixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snownix.InvoicesFixtures

  @create_attrs %{
    allow_edit: true,
    currency: "some currency",
    discount: 42,
    discount_per_item: true,
    discount_type: "some discount_type",
    discount_val: 42,
    due_amount: 42,
    due_date: %{day: 4, hour: 14, minute: 27, month: 6, year: 2022},
    from_date: %{day: 4, hour: 14, minute: 27, month: 6, year: 2022},
    invoice_number: "some invoice_number",
    note: "some note",
    paid_status: "some paid_status",
    reference_number: "some reference_number",
    sent_email: true,
    sent_sms: true,
    sequence_number: 42,
    status: "some status",
    sub_total: 42,
    tax: 42,
    tax_per_item: true,
    to_date: %{day: 4, hour: 14, minute: 27, month: 6, year: 2022},
    total: 42,
    viewed: 42
  }
  @update_attrs %{
    allow_edit: false,
    currency: "some updated currency",
    discount: 43,
    discount_per_item: false,
    discount_type: "some updated discount_type",
    discount_val: 43,
    due_amount: 43,
    due_date: %{day: 5, hour: 14, minute: 27, month: 6, year: 2022},
    from_date: %{day: 5, hour: 14, minute: 27, month: 6, year: 2022},
    invoice_number: "some updated invoice_number",
    note: "some updated note",
    paid_status: "some updated paid_status",
    reference_number: "some updated reference_number",
    sent_email: false,
    sent_sms: false,
    sequence_number: 43,
    status: "some updated status",
    sub_total: 43,
    tax: 43,
    tax_per_item: false,
    to_date: %{day: 5, hour: 14, minute: 27, month: 6, year: 2022},
    total: 43,
    viewed: 43
  }
  @invalid_attrs %{
    allow_edit: false,
    currency: nil,
    discount: nil,
    discount_per_item: false,
    discount_type: nil,
    discount_val: nil,
    due_amount: nil,
    due_date: %{day: 30, hour: 14, minute: 27, month: 2, year: 2022},
    from_date: %{day: 30, hour: 14, minute: 27, month: 2, year: 2022},
    invoice_number: nil,
    note: nil,
    paid_status: nil,
    reference_number: nil,
    sent_email: false,
    sent_sms: false,
    sequence_number: nil,
    status: nil,
    sub_total: nil,
    tax: nil,
    tax_per_item: false,
    to_date: %{day: 30, hour: 14, minute: 27, month: 2, year: 2022},
    total: nil,
    viewed: nil
  }

  defp create_invoice(_) do
    invoice = invoice_fixture()
    %{invoice: invoice}
  end

  describe "Index" do
    setup [:create_invoice]

    test "lists all invoices", %{conn: conn, invoice: invoice} do
      {:ok, _index_live, html} = live(conn, Routes.admin_invoice_index_path(conn, :index))

      assert html =~ "Listing Invoices"
      assert html =~ invoice.currency
    end

    test "saves new invoice", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_invoice_index_path(conn, :index))

      assert index_live |> element("a", "New Invoice") |> render_click() =~
               "New Invoice"

      assert_patch(index_live, Routes.admin_invoice_index_path(conn, :new))

      assert index_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#invoice-form", invoice: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_invoice_index_path(conn, :index))

      assert html =~ "Invoice created successfully"
      assert html =~ "some currency"
    end

    test "updates invoice in listing", %{conn: conn, invoice: invoice} do
      {:ok, index_live, _html} = live(conn, Routes.admin_invoice_index_path(conn, :index))

      assert index_live |> element("#invoice-#{invoice.id} a", "Edit") |> render_click() =~
               "Edit Invoice"

      assert_patch(index_live, Routes.admin_invoice_index_path(conn, :edit, invoice))

      assert index_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#invoice-form", invoice: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_invoice_index_path(conn, :index))

      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated currency"
    end

    test "deletes invoice in listing", %{conn: conn, invoice: invoice} do
      {:ok, index_live, _html} = live(conn, Routes.admin_invoice_index_path(conn, :index))

      assert index_live |> element("#invoice-#{invoice.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#invoice-#{invoice.id}")
    end
  end

  describe "Show" do
    setup [:create_invoice]

    test "displays invoice", %{conn: conn, invoice: invoice} do
      {:ok, _show_live, html} = live(conn, Routes.admin_invoice_show_path(conn, :show, invoice))

      assert html =~ "Show Invoice"
      assert html =~ invoice.currency
    end

    test "updates invoice within modal", %{conn: conn, invoice: invoice} do
      {:ok, show_live, _html} = live(conn, Routes.admin_invoice_show_path(conn, :show, invoice))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Invoice"

      assert_patch(show_live, Routes.admin_invoice_show_path(conn, :edit, invoice))

      assert show_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#invoice-form", invoice: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_invoice_show_path(conn, :show, invoice))

      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated currency"
    end
  end
end
