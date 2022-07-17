defmodule Snownix.InvoicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snownix.Invoices` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        allow_edit: true,
        currency: "MAD",
        discount: 42,
        discount_per_item: true,
        discount_type: "some discount_type",
        discount : 42,
        due_amount: 42,
        due_date: ~U[2022-06-13 00:00:00Z],
        from_date: ~U[2022-06-13 00:00:00Z],
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
        to_date: ~U[2022-06-13 00:00:00Z],
        total: 42,
        viewed: false
      })
      |> Snownix.Invoices.create_invoice()

    invoice
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        description: "some description",
        discount: 42,
        name: "some name",
        price: 42,
        quantity: 42,
        tax: 42,
        total: 42,
        unit_name: "some unit_name"
      })
      |> Snownix.Invoices.create_item()

    item
  end
end
