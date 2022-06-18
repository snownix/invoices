defmodule Snownix.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  import Snownix.Helpers.Sorting

  alias Snownix.Repo
  alias Snownix.Projects
  alias Snownix.Customers.User
  alias Snownix.Organizations.Project

  @topic inspect(__MODULE__)
  @activity_field :contact_name
  @activity_field_address :street

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

  @doc """
  Returns the list of customer_users.

  ## Examples

      iex> list_customer_users("ffffffff-ffff-ffff-ffff-ffffffffffff")
      [%Ecto.Query{}, ...]

  """
  def list_customer_users() do
    User |> Repo.all()
  end

  def list_customer_users(%Project{} = project) do
    list_customer_users(project.id, [])
  end

  def list_customer_users(project_id, opts \\ []) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from(c in User,
        where:
          c.project_id ==
            ^project_id
      )

    sort_query_by(query, orderby, order)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("4648226a-d30a-4619-ad36-7102c720d08a")
      %User{}

      iex> get_user!("ffffffff-ffff-ffff-ffff-ffffffffffff")
      ** (Ecto.NoResultsError)

  """
  def get_user!(id),
    do:
      Repo.get!(User, id)
      |> Repo.preload(:addresses)

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
  def create_user(project \\ nil, user \\ nil, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> User.project_changeset(project)
    |> User.owner_changeset(user)
    |> Repo.insert()
    |> notify_subscribers([:customer, :created])
    |> Projects.log_activity(project, user, :create, @activity_field)
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

  def update_user(%User{} = cuser, attrs, project, user) do
    update_user(cuser, attrs)
    |> Projects.log_activity(project, user, :update, @activity_field)
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = cuser) do
    Repo.delete(cuser)
    |> notify_subscribers([:customer, :deleted])
  end

  def delete_user(%User{} = cuser, project, user) do
    delete_user(cuser)
    |> Projects.log_activity(project, user, :delete, @activity_field)
  end

  def delete_users(project_id, ids) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(
        :delete_all,
        from(u in User, where: u.project_id == ^project_id and u.id in ^ids)
      )
      |> Repo.transaction()

    notify_subscribers({:ok, %User{project_id: project_id}}, [:customer, :deleted_many])
    result
  end

  def clone_users(project_id, ids) do
    users =
      from(u in User, where: u.project_id == ^project_id and u.id in ^ids)
      |> Repo.all()
      |> Enum.map(fn item ->
        Map.take(item, User.__schema__(:fields))
        |> Map.delete(:id)
        |> Map.put(:contact_name, "Clone - #{item.contact_name}")
      end)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, User, users, returning: [:id])
      |> Repo.transaction()

    notify_subscribers({:ok, %User{project_id: project_id}}, [:customer, :created_many])
    result
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
  def create_address(attrs, project, user, customer) do
    %Address{}
    |> Address.changeset(attrs)
    |> Address.project_changeset(project)
    |> Address.customer_changeset(customer)
    |> Repo.insert()
    |> notify_subscribers(attrs["user_id"], [:address, :created])
    |> Projects.log_activity(project, user, :update, @activity_field_address)
  end

  def create_address(attrs) do
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

  def update_address(%Address{} = address, project, user, attrs) do
    update_address(address, attrs)
    |> Projects.log_activity(project, user, :update, @activity_field_address)
  end

  def change_default_address(address, project, user, addresses) do
    old_default = Enum.find(addresses, & &1.default)

    address
    |> switch_default_address(old_default)
    |> notify_subscribers(address.user_id, [:address, :updated])
    |> Projects.log_activity(project, user, :update, @activity_field_address)
  end

  defp switch_default_address(new_default, nil) do
    new_default
    |> Ecto.Changeset.change(%{default: true})
    |> Repo.update()
  end

  defp switch_default_address(new_default, old_default) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:new, Ecto.Changeset.change(new_default, %{default: true}))
    |> Ecto.Multi.update(:old, Ecto.Changeset.change(old_default, %{default: false}))
    |> Repo.transaction()
    |> case do
      {:ok, %{new: address}} ->
        {:ok, address}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
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

  def delete_address(%Address{} = address, project, user) do
    delete_address(address)
    |> Projects.log_activity(project, user, :delete, @activity_field_address)
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
