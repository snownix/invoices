defmodule Snownix.Helpers.Changeset do
  alias Ecto.Changeset

  def cast_float_to_int(%Changeset{} = changeset, fields) when is_list(fields) do
    fields
    |> Enum.map(fn {float_key, int_key} ->
      changeset
      |> Changeset.get_change(float_key, 0)
      |> then(fn val -> val * 100 end)
      |> round()
      |> then(&{int_key, &1})
    end)
    |> then(&Changeset.change(changeset, &1))
  end

  def cast_float_to_int(%Changeset{} = changeset, float_key, int_key)
      when is_atom(float_key) and is_atom(int_key) do
    changeset
    |> Changeset.get_change(float_key, 0)
    |> then(fn val -> val * 100 end)
    |> round()
    |> then(&Changeset.change(changeset, [{int_key, &1}]))
  end
end
