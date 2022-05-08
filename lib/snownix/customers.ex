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

    Phoenix.PubSub.broadcast(
      Snownix.PubSub,
      @topic <> "#{project_id}" <> "#{result.id}",
      {__MODULE__, event, result}
    )

    {:ok, result}
  end

  # defp notify_subscribers({:error, reason}, _, _b), do: {:error, reason}

  @doc """
  Returns the list of customer_users.

  ## Examples

      iex> list_customer_users("ffffffff-ffff-ffff-ffff-ffffffffffff")
      [%Ecto.Query{}, ...]

  """
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
  def get_user!(id), do: Repo.get!(User, id)

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
end
