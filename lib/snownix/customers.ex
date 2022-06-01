defmodule Snownix.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  alias Snownix.Repo

  alias Snownix.Customers.User

  @topic inspect(__MODULE__)

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

  defp notify_subscribers({:ok, result}, parent_id, event) do
    project_id = result.project_id

    Phoenix.PubSub.broadcast(
      Snownix.PubSub,
      @topic <> "#{project_id}" <> "#{parent_id}",
      {__MODULE__, event, result}
    )

    {:ok, result}
  end

  defp notify_subscribers({:error, changeset}, _parent_id, _event), do: {:error, changeset}
  # defp notify_subscribers({:error, changeset}, _event), do: {:error, changeset}

  @doc """
  Returns the list of customer_users.

  ## Examples

      iex> list_customer_users("ffffffff-ffff-ffff-ffff-ffffffffffff")
      [%Ecto.Query{}, ...]

  """
  def list_customer_users() do
    User |> Repo.all()
  end

  def list_customer_users(project_id, opts) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from(c in User,
        where:
          c.project_id ==
            ^project_id
      )

    sort_customers_by(query, orderby, order)
  end

  def sort_customers_by(query, nil, _), do: query

  def sort_customers_by(query, orderby, :asc), do: query |> order_by(asc: ^orderby)
  def sort_customers_by(query, orderby, :desc), do: query |> order_by(desc: ^orderby)
  def sort_customers_by(query, _, _), do: query

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("4648226a-d30a-4619-ad36-7102c720d08a")
      %User{}

      iex> get_user!("ffffffff-ffff-ffff-ffff-ffffffffffff")
      ** (Ecto.NoResultsError)

  """
  def get_user!(project_id, id),
    do:
      from(u in User, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()
      |> Repo.preload(:addresses)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(project, author, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> User.project_changeset(project)
    |> User.owner_changeset(author)
    |> Repo.insert()
    |> notify_subscribers([:customer, :created])
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:customer, :updated])
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
    |> notify_subscribers([:customer, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Snownix.Customers.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
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
  def get_address!(id), do: Repo.get!(Address, id)

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
    |> notify_subscribers(attrs["user_id"], [:address, :created])
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
    |> notify_subscribers(address.user_id, [:address, :updated])
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
    address
    |> Repo.delete()
    |> notify_subscribers(address.user_id, [:address, :deleted])
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