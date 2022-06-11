defmodule Snownix.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  import Snownix.Helpers.Sorting

  alias Snownix.Repo
  alias Snownix.Projects

  alias Snownix.Products.Category

  @topic inspect(__MODULE__)

  @activity_field :name

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

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories() do
    Repo.all(Category)
  end

  def list_categories(project_id) do
    query =
      from c in Category,
        where: c.project_id == ^project_id

    Repo.all(query)
  end

  def list_categories(project_id, opts) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from c in Category,
        where: c.project_id == ^project_id

    sort_query_by(query, orderby, order)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id),
    do: Repo.get!(Category, id)

  def get_category!(project_id, id),
    do:
      from(u in Category, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:category, :created])
  end

  def create_category(project, user, attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Category.project_changeset(project)
    |> Category.owner_changeset(user)
    |> Repo.insert()
    |> notify_subscribers([:category, :created])
    |> Projects.log_activity(project, user, :create, @activity_field)
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:category, :created])
  end

  def update_category(%Category{} = category, attrs, project, user) do
    update_category(category, attrs)
    |> Projects.log_activity(project, user, :update, @activity_field)
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
    |> notify_subscribers([:category, :deleted])
  end

  def delete_category(%Category{} = category, project, user) do
    delete_category(category)
    |> Projects.log_activity(project, user, :delete, @activity_field)
  end

  def categories_by_ids_query(project_id, ids) do
    from u in Category,
      where: u.project_id == ^project_id and u.id in ^ids
  end

  def delete_categories(project_id, ids) do
    project_id
    |> categories_by_ids_query(ids)
    |> Repo.delete_all()

    notify_subscribers({:ok, %Category{project_id: project_id}}, [:category, :deleted_many])
  end

  def clone_categories(project_id, ids) do
    categories =
      project_id
      |> categories_by_ids_query(ids)
      |> Repo.all()
      |> Enum.map(fn item ->
        Map.take(item, Category.__schema__(:fields))
        |> Map.delete(:id)
        |> Map.put(:name, "Clone - #{item.name}")
      end)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, Category, categories, returning: [:id])
      |> Repo.transaction()

    notify_subscribers({:ok, %Category{project_id: project_id}}, [:category, :created_many])
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Snownix.Products.Unit

  @doc """
  Returns the list of units.

  ## Examples

      iex> list_units()
      [%Unit{}, ...]

  """
  def list_units do
    Repo.all(Unit)
  end

  @doc """
  Gets a single unit.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123)
      %Unit{}

      iex> get_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id), do: Repo.get!(Unit, id)

  @doc """
  Creates a unit.

  ## Examples

      iex> create_unit(%{field: value})
      {:ok, %Unit{}}

      iex> create_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:unit, :inserted])
  end

  @doc """
  Updates a unit.

  ## Examples

      iex> update_unit(unit, %{field: new_value})
      {:ok, %Unit{}}

      iex> update_unit(unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:unit, :updated])
  end

  @doc """
  Deletes a unit.

  ## Examples

      iex> delete_unit(unit)
      {:ok, %Unit{}}

      iex> delete_unit(unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
    |> notify_subscribers([:unit, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unit changes.

  ## Examples

      iex> change_unit(unit)
      %Ecto.Changeset{data: %Unit{}}

  """
  def change_unit(%Unit{} = unit, attrs \\ %{}) do
    Unit.changeset(unit, attrs)
  end

  alias Snownix.Products.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products() do
    Repo.all(Product)
  end

  def list_products(project_id, opts) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from c in Product,
        where: c.project_id == ^project_id

    sort_query_by(query, orderby, order)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """

  def get_product!(id), do: Repo.get!(Product, id)

  def get_product!(project_id, id),
    do:
      from(u in Product, where: u.project_id == ^project_id and u.id == ^id)
      |> Repo.one!()

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:product, :created])
  end

  def create_product(project, user, category, attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Product.change_user(user)
    |> Product.change_project(project)
    |> Product.change_category(category)
    |> Repo.insert()
    |> notify_subscribers([:product, :created])
    |> Projects.log_activity(project, user, :create, @activity_field)
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:product, :updated])
  end

  def update_product(%Product{} = product, %Category{} = category, attrs) do
    product
    |> Repo.preload(:category)
    |> Product.changeset(attrs)
    |> Product.change_category(category)
    |> Repo.update()
    |> notify_subscribers([:product, :updated])
  end

  def update_product(%Product{} = product, project, user, %Category{} = category, attrs) do
    update_product(product, category, attrs)
    |> Projects.log_activity(project, user, :update, @activity_field)
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
    |> notify_subscribers([:product, :deleted])
  end

  def delete_product(%Product{} = product, project, user) do
    delete_product(product)
    |> Projects.log_activity(project, user, :delete, @activity_field)
  end

  def delete_products(project_id, ids) do
    query =
      from u in Product,
        where: u.project_id == ^project_id and u.id in ^ids

    Repo.delete_all(query)

    notify_subscribers({:ok, %Product{project_id: project_id}}, [:product, :deleted_many])
  end

  def clone_products(project_id, ids) do
    products =
      from(u in Product, where: u.project_id == ^project_id and u.id in ^ids)
      |> Repo.all()
      |> Enum.map(fn item ->
        Map.take(item, Product.__schema__(:fields))
        |> Map.delete(:id)
        |> Map.put(:name, "Clone - #{item.name}")
      end)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert_all(:insert_all, Product, products, returning: [:id])
      |> Repo.transaction()

    notify_subscribers({:ok, %Product{project_id: project_id}}, [:product, :created_many])
    result
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
