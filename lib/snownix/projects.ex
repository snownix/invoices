defmodule Snownix.Projects do
  @moduledoc """
  The Project context.
  """

  import Ecto.Query, warn: false
  alias Snownix.Repo

  alias Snownix.Projects.Tax

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
  def create_tax(tax, project, user, attrs \\ %{}) do
    %Tax{}
    |> Tax.changeset(attrs)
    |> Tax.owner_changeset(project, user)
    |> Repo.insert()
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
end
