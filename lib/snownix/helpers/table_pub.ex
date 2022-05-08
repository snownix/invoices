defmodule Snownix.Helpers.TablePub do
  import Phoenix.LiveView

  def handle_table_pub(module, socket, listname, rowname, {_, [_atom, type], item}) do
    list = socket.assigns[listname]
    row = socket.assigns[rowname]

    {:noreply,
     case type do
       :deleted ->
         socket
         |> assign(listname, Enum.reject(list, &(&1.id == item.id)))
         |> module.push_index

       :updated ->
         socket
         |> assign(
           listname,
           Enum.map(list, &if(&1.id == item.id, do: item, else: &1))
         )
         |> assign(
           rowname,
           if(!is_nil(row) and row.id == item.id,
             do: item,
             else: row
           )
         )

       _ ->
         socket |> module.fetch
     end}
  end
end
