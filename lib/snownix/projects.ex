defmodule Snownix.Projects do
  @moduledoc """
  The Project context.
  """

  import Ecto.Query, warn: false
  import Snownix.Helpers.Sorting

  alias Snownix.Repo
  alias Snownix.Projects.Tax

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

  defp notify_subscribers({:error, changeset}, _event) do
    {:error, changeset}
  end

  @doc """
  Returns the list of taxs.

  ## Examples

      iex> list_taxs()
      [%Tax{}, ...]

  """
  def list_taxs do
    Repo.all(Tax)
  end

  def list_taxs(project) do
    query = from t in Tax, where: t.project_id == ^project.id
    Repo.all(query)
  end

  @doc """
  Gets a single tax.

  Raises `Ecto.NoResultsError` if the Tax does not exist.

  ## Examples

      iex> get_tax!(123)
      %Tax{}

      iex> get_tax!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tax!(id), do: Repo.get!(Tax, id)

  @doc """
  Creates a tax.

  ## Examples

      iex> create_tax(%{field: value})
      {:ok, %Tax{}}

      iex> create_tax(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tax(project, user, attrs \\ %{}) do
    %Tax{}
    |> Tax.changeset(attrs)
    |> Tax.owner_changeset(project, user)
    |> Repo.insert()
    |> log_activity(project, user, :create)
  end

  @doc """
  Updates a tax.

  ## Examples

      iex> update_tax(tax, %{field: new_value})
      {:ok, %Tax{}}

      iex> update_tax(tax, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tax(%Tax{} = tax, project, user, attrs) do
    tax
    |> Tax.changeset(attrs)
    |> Tax.owner_changeset(project, user)
    |> Repo.update()
    |> log_activity(project, user, :update)
  end

  @doc """
  Deletes a tax.

  ## Examples

      iex> delete_tax(tax)
      {:ok, %Tax{}}

      iex> delete_tax(tax)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tax(%Tax{} = tax) do
    Repo.delete(tax)
  end

  def delete_tax(%Tax{} = tax, project, user) do
    delete_tax(tax)
    |> log_activity(project, user, :delete)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tax changes.

  ## Examples

      iex> change_tax(tax)
      %Ecto.Changeset{data: %Tax{}}

  """
  def change_tax(%Tax{} = tax, project, user, attrs \\ %{}) do
    Tax.changeset(tax, attrs)
    |> Tax.owner_changeset(project, user)
  end

  alias Snownix.Projects.Activity

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities() do
    Repo.all(Activity)
  end

  def list_activities(project_id, opts \\ []) do
    orderby = Keyword.get(opts, :order_by)
    order = Keyword.get(opts, :order, :asc)

    query =
      from(a in Activity,
        where:
          a.project_id ==
            ^project_id
      )

    sort_query_by(query, orderby, order)
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id), do: Repo.get!(Activity, id)

  @doc """
  Creates a activity.

  ## Examples

      iex> create_activity(%{field: value})
      {:ok, %Activity{}}

      iex> create_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_activity(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:activity, :created])
  end

  def create_activity(attrs \\ %{}, project, user) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Activity.owner_changeset(project, user)
    |> Repo.insert()
    |> notify_subscribers([:activity, :created])
  end

  @doc """
  Updates a activity.

  ## Examples

      iex> update_activity(activity, %{field: new_value})
      {:ok, %Activity{}}

      iex> update_activity(activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:activity, :updated])
  end

  @doc """
  Deletes a activity.

  ## Examples

      iex> delete_activity(activity)
      {:ok, %Activity{}}

      iex> delete_activity(activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
    |> notify_subscribers([:activity, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{data: %Activity{}}

  """
  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end

  @doc """
  Create new activity

  ## Examples

      iex> log_activity(%{ok, changeset}, project, user, :create, :firstname)
  """
  def log_activity(result, project, user, action, field \\ :name, note \\ nil) do
    case result do
      {:ok, item} ->
        %name{} = item
        name = "#{name}" |> String.split(".") |> List.last()

        create_activity(
          %{
            title: "#{action} #{name} **#{Map.get(item, field)}**",
            from:
              (user && Map.has_key?(user, :firstname) && user.firstname <> " " <> user.lastname) ||
                nil,
            to: (project && Map.has_key?(project, :name) && project.name) || nil,
            target_id: item.id,
            action: "#{action}",
            name: Map.get(item, field),
            type: name,
            note: note
          },
          project,
          user
        )

        result

      _ ->
        result
    end
  end
end
