defmodule Snownix.Helpers.Changeset do
  @moduledoc """
  The changeset helpers.
  """

  alias Ecto.Changeset

  def cast_float_to_int(%Changeset{} = changeset, fields) when is_list(fields) do
    fields
    |> Enum.reduce(changeset, fn {float_key, int_key}, changeset_acc ->
      cast_float_to_int(changeset_acc, float_key, int_key)
    end)
  end

  def cast_float_to_int(%Changeset{} = changeset, float_key, int_key)
      when is_atom(float_key) and is_atom(int_key) do
    case changeset |> Changeset.get_change(float_key, nil) do
      nil ->
        changeset

      val ->
        (val * 100)
        |> round()
        |> then(&Changeset.change(changeset, [{int_key, &1}]))
    end
  end

  def cast_int_to_float(%Changeset{} = changeset, fields) when is_list(fields) do
    fields
    |> Enum.reduce(changeset, fn {int_key, float_key}, changeset_acc ->
      cast_int_to_float(changeset_acc, int_key, float_key)
    end)
  end

  def cast_int_to_float(item, fields) when is_list(fields) do
    fields
    |> Enum.reduce(item, fn {int_key, float_key}, item_acc ->
      cast_int_to_float(item_acc, int_key, float_key)
    end)
  end

  def cast_int_to_float(%Changeset{} = changeset, int_key, float_key)
      when is_atom(float_key) and is_atom(int_key) do
    case changeset |> Changeset.get_change(int_key, nil) do
      nil ->
        changeset

      val ->
        (val / 100)
        |> then(&Changeset.change(changeset, [{float_key, &1}]))
    end
  end

  def cast_int_to_float(item, int_key, float_key) do
    item
    |> Map.put(
      float_key,
      Map.get(item, int_key) / 100
    )
  end

  @doc """
  Apply discount to a price

  ## Examples

      iex> apply_discount("fixed", 10_000, 1_000)
      9_000

      iex> apply_discount("percentage", 10_000, 20_00)
      8_000
  iex>
  """
  def apply_discount("fixed", price, discount),
    do: price - calc_discount("fixed", price, discount)

  def apply_discount("percentage", price, discount),
    do: price - calc_discount("percentage", price, discount)

  @doc """
  Calculate discount based on a price

  ## Examples

      iex> calc_discount("fixed", 10_000, 1_000)
      1_000

      iex> calc_discount("percentage", 10_000, 20_00)
      2_000
  iex>
  """
  def calc_discount("fixed", _price, discount), do: discount

  def calc_discount("percentage", price, discount) do
    (price * discount / 10_000)
    |> Kernel.floor()
  end

  @doc """
  Format an integer to a floating point with 2 franctional digits
  """
  def float_format(number) when is_integer(number) do
    Float.round(number / 100, 2)
    |> :erlang.float_to_binary(decimals: 2)
  end

  def float_format(_), do: nil
end
