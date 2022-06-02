defmodule Snownix.Helpers.Sorting do
  import Ecto.Query, warn: false

  def sort_query_by(query, nil, _), do: query

  def sort_query_by(query, orderby, :asc), do: query |> order_by(asc: ^orderby)
  def sort_query_by(query, orderby, :desc), do: query |> order_by(desc: ^orderby)
  def sort_query_by(query, _, _), do: query
end
