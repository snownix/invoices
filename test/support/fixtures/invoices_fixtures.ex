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
        currency: "some currency",
        discount: 42,
        discount_per_item: true,
        discount_type: "some discount_type",
        discount_val: 42,
        due_amount: 42,
        due_date: ~N[2022-06-04 14:27:00],
        from_date: ~N[2022-06-04 14:27:00],
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
        to_date: ~N[2022-06-04 14:27:00],
        total: 42,
        viewed: 42
      })
      |> Snownix.Invoices.create_invoice()

    invoice
  end
end
