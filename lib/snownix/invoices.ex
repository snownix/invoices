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

  def invoice_customer(query) do
    query |> Repo.preload(:customer)
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

  def invoice_assign_customer(query, %Project{} = project, %{"customer_id" => customer_id}) do
    customer = Customers.get_user!(project.id, customer_id)

    query
    |> Invoice.customer_changeset(customer)
  end

  def invoice_assign_customer(query, %Project{} = _project, _attrs), do: query

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:invoice, :created])
  end

  def create_invoice(project, user, attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Invoice.owner_changeset(user)
    |> Invoice.project_changeset(project)
    |> invoice_assign_customer(project, attrs)
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
    |> invoice_assign_customer(project, attrs)
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
        Map.take(item, Invoice.__schema__(:fields))
        |> Map.delete(:id)
        |> Map.put(:name, "Clone - #{item.title}")
      end)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, Invoice, invoices, returning: [:id])
      |> Repo.transaction()

    notify_subscribers({:ok, %Invoice{project_id: project_id}}, [:invoice, :created_many])
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end
end
