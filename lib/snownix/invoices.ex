defmodule Snownix.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  import Snownix.Helpers.Sorting

  alias Snownix.Repo
  alias Snownix.Projects
  alias Snownix.Customers
  alias Snownix.Organizations.Project

  @topic inspect(__MODULE__)

  @activity_field :invoice_number
  @activity_group_field :name

  def subscribe(project_id) do
    Phoenix.PubSub.subscribe(Snownix.PubSub, @topic <> "#{project_id}")
  end

  def subscribe(project_id, item_id) do
    Phoenix.PubSub.subscribe(Snownix.PubSub, @topic <> "#{project_id}" <> "#{item_id}")
  end

  defp notify_subscribers({:ok, result}, event) do
    project_id = result.project_id

    Phoenix.PubSub.broadcast(
      Snownix.PubSub,
      @topic <> "#{project_id}",
      {__MODULE__, event, result}
    )

    notify_subscribers(
      {:ok, result},
      result.id,
      event
    )
  end

  defp notify_subscribers({:error, changeset}, _event), do: {:error, changeset}

  defp notify_subscribers({:ok, result}, parent_id, event) do
    project_id = result.project_id

    Phoenix.PubSub.broadcast(
      Snownix.PubSub,
      @topic <> "#{project_id}" <> "#{parent_id}",
      {__MODULE__, event, result}
    )

    {:ok, result}
  end

  alias Snownix.Invoices.Item
  alias Snownix.Invoices.Invoice

  def get_last_sequence_number() do
    seq =
      Repo.one(
        from u in Invoice, select: u.sequence_number, order_by: [desc: :sequence_number], limit: 1
      )

    if seq do
      seq
    else
      0
    end
  end

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices() do
    Repo.all(Invoice)
  end

  def list_invoices(%Project{} = project, opts \\ []) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from i in Invoice,
        where: i.project_id == ^project.id

    sort_query_by(query, orderby, order)
  end

  def customer(query) do
    query
    |> Repo.preload(:customer)
  end

  def items(query) do
    query
    |> Repo.preload(:items)
  end

  def invoice_calcs(%Invoice{} = invoice) do
    invoice
    |> Invoice.update_calcs()
  end

  def invoice_calcs(invoices) when is_list(invoices) do
    invoices
    |> Enum.map(&invoice_calcs(&1))
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id),
    do: Repo.get!(Invoice, id)

  def get_invoice!(%Project{} = project, id),
    do: get_invoice!(project.id, id)

  def get_invoice!(project_id, id),
    do:
      from(u in Invoice, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()
      |> Repo.preload(:items)
      |> Repo.preload(:customer)
      |> Repo.preload(:billing_address)
      |> Repo.preload(:shipping_address)
      |> invoice_calcs()

  def assign_customer(query, %Project{} = project, %{"customer_id" => customer_id}) do
    customer = Customers.get_user!(project.id, customer_id)

    query
    |> Invoice.customer_changeset(customer)
  end

  def assign_customer(query, %Project{} = _project, _attrs), do: query

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%Invoice{}, %{title: "Invoice X"})
      {:ok, %Invoice{}}

      iex> create_invoice(%Invoice{}, %{title: "Invoice X"})
      {:error, %Ecto.Changeset{}}

  """

  def create_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:invoice, :created])
  end

  def create_invoice(attrs \\ %{}) do
    create_invoice(%Invoice{}, attrs)
  end

  @doc """
  ## Examples

      iex> create_invoice(%Invoice{}, %Project{}, %User{}, %{title: "Invoice Y"})
      {:ok, %Invoice{}}

      iex> create_invoice(%Invoice{}, %Project{}, %User{}, %{title: "Invoice Y"})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(%Project{} = project, user, attrs),
    do: create_invoice(%Invoice{}, project, user, attrs)

  def create_invoice(%Invoice{} = invoice, project, user, attrs \\ %{}) do
    invoice
    |> Invoice.changeset(attrs)
    |> Invoice.owner_changeset(user)
    |> Invoice.project_changeset(project)
    |> assign_customer(project, attrs)
    |> Repo.insert()
    |> notify_subscribers([:invoice, :created])
    |> Projects.log_activity(project, user, :create, @activity_field)
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:invoice, :updated])
  end

  def update_invoice(%Invoice{} = invoice, %Project{} = project, attrs) do
    invoice
    |> Repo.preload(:customer)
    |> Invoice.changeset(attrs)
    |> assign_customer(project, attrs)
    |> Repo.update()
    |> notify_subscribers([:invoice, :updated])
  end

  def update_invoice(%Invoice{} = invoice, %Project{} = project, user, attrs) do
    update_invoice(invoice, project, attrs)
    |> Projects.log_activity(project, user, :update, @activity_field)
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
    |> notify_subscribers([:invoice, :deleted])
  end

  def delete_invoice(%Invoice{} = invoice, project, user) do
    delete_invoice(invoice)
    |> Projects.log_activity(project, user, :delete, @activity_field)
  end

  def delete_invoices(project_id, ids) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(
        :delete_all,
        from(u in Invoice, where: u.project_id == ^project_id and u.id in ^ids)
      )
      |> Repo.transaction()

    notify_subscribers({:ok, %Invoice{project_id: project_id}}, [:invoice, :deleted_many])
    result
  end

  def clone_invoices(project_id, ids) do
    invoices =
      from(u in Invoice, where: u.project_id == ^project_id and u.id in ^ids)
      |> Repo.all()
      |> Enum.map(fn item ->
        item =
          item
          |> Repo.preload(:items)

        # items =
        #   item.items
        #   |> Map.take([Item.__schema__(:fields)])
        #   |> Enum.map(&Map.delete(&1, [:id, :invoice_id]))

        item
        |> Map.take([
          :parent_id,
          :customer_id,
          :user_id,
          :project_id | Invoice.__schema__(:fields)
        ])
        |> Map.put(:parent_id, item.id)
        |> Map.delete(:id)
        |> Map.put(:title, "#{item.title}-1")
        |> Map.put(:reference_number, "#{item.reference_number}-1")

        # |> Map.put(:items, items)
      end)

    result = {:ok, []}

    Repo.transaction(fn ->
      invoices
      |> Enum.map(fn invoice ->
        row = Repo.insert!(Invoice.changeset(%Invoice{}, invoice))

        # items =
        #   invoice
        #   |> then(& &1.items)
        #   |> Enum.map(&Map.drop(&1, [:id, :invoice_id]))

        # Repo.update!(Invoice.items_changeset(row, items))
        row.id
      end)
    end)

    notify_subscribers({:ok, %Invoice{project_id: project_id}}, [:invoice, :created_many])
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end

  alias Snownix.Invoices.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def delete_items([]), do: {:ok, nil}

  def delete_items(items) do
    Repo.delete_all(items)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  alias Snownix.Invoices.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups() do
    Repo.all(Group)
  end

  def list_groups(%Project{} = project) do
    from(i in Group,
      where:
        i.project_id ==
          ^project.id
    )
    |> Repo.all()
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  def get_group!(%Project{} = project, id),
    do: get_group!(project.id, id)

  def get_group!(project_id, id),
    do:
      from(u in Group, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:group, :inserted])
  end

  def create_group(project, user, attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Group.owner_changeset(project, user)
    |> Repo.insert()
    |> notify_subscribers([:group, :inserted])
    |> Projects.log_activity(project, user, :create, @activity_group_field)
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:group, :updated])
  end

  def update_group(%Group{} = group, project, user, attrs) do
    group
    |> Group.changeset(attrs)
    |> Group.owner_changeset(project, user)
    |> Repo.update()
    |> notify_subscribers([:group, :updated])
    |> Projects.log_activity(project, user, :update, @activity_group_field)
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
    |> notify_subscribers([:group, :deleted])
  end

  def delete_group(%Group{} = group, project, user) do
    delete_group(group)
    |> Projects.log_activity(project, user, :delete, @activity_group_field)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Identifier Format

    {{ID}} Next ID
    {{Y}} Year
    {{M}} Month
    {{D}} Day
    {{NAME}} Name
  """
  def identifier_format(format, data \\ %{}) do
    %{year: year, month: month, day: day} = Date.utc_today()

    fields =
      Map.merge(
        %{
          y: year,
          m: month,
          d: day,
          name: "",
          left_pad: 0,
          next_id: 0
        },
        data
      )

    [
      {"Y", fields.y},
      {"M", fields.m},
      {"D", fields.d},
      {"NAME", fields.name},
      {"ID",
       "#{fields.next_id}"
       |> String.pad_leading(cast_str_to_int(fields.left_pad), "0")}
    ]
    |> Enum.reduce(
      "#{format}",
      fn {field, value}, acc ->
        acc |> String.replace("\{\{#{field}\}\}", "#{value}")
      end
    )
  end

  defp cast_str_to_int(val),
    do: if(is_number(val), do: val, else: String.to_integer(val))

  alias Snownix.Invoices.Address

  @doc """
  Returns the list of invoice_addresses.

  ## Examples

      iex> list_invoice_addresses()
      [%Address{}, ...]

  """
  def list_invoice_addresses do
    Repo.all(Address)
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id),
    do:
      Repo.get!(Address, id)
      |> Repo.preload(:addresses)

  def get_address!(%Project{} = project, id), do: get_address!(project.id, id)

  def get_address!(project_id, id),
    do:
      from(u in Address, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()
      |> Repo.preload(:addresses)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: value})
      {:ok, %Address{}}

      iex> create_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(address)
      %Ecto.Changeset{data: %Address{}}

  """
  def change_address(%Address{} = address, attrs \\ %{}) do
    Address.changeset(address, attrs)
  end
end
