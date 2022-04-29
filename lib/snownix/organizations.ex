defmodule Snownix.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Snownix.Repo

  alias Snownix.Organizations.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  def get_project_by_user(user, id) do
    query =
      from(p in Project, join: u in assoc(p, :users), where: p.id == ^id and u.id == ^user.id)

    Repo.one(query)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(owner, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Project.owner_changeset(owner)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Project.address_changeset(attrs)
    |> Project.preferences_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
    |> Project.address_changeset(attrs)
  end

  def change_project_preferences(%Project{} = project, attrs \\ %{}) do
    Project.preferences_changeset(project, attrs)
  end

  @doc """
  Updates the project logo.

  The project logo is updated .
  The old logo is deleted
  The confirmed_at date is also updated to the current time.
  """
  def update_project_logo(project, logo) do
    changeset =
      project
      |> Project.logo_changeset(%{logo: logo})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:project, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{project: project}} -> {:ok, project}
      {:error, :project, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Delete the project logo.

  The update_project_logo is called with logo nil value
  """
  def delete_project_logo(project) do
    update_project_logo(project, nil)
  end
end
