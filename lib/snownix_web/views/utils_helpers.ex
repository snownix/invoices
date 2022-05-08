defmodule SnownixWeb.UtilsHelpers do
  @moduledoc """
  Utils.
  """

  def get_user_avatar(user) do
    if is_nil(user) or is_nil(user.avatar) do
      nil
    else
      Snownix.Uploaders.AvatarUploader.url({user.avatar, user}, :thumb)
    end
  end

  def get_user_avatar_text(user) do
    if Map.has_key?(user, :firstname) do
      String.at(user.firstname, 0) <> String.at(user.lastname, 0)
    else
      slice_name(user.contact_name, 0, 2)
    end
  end

  def get_user_fullname(user) do
    user.firstname <> " " <> user.lastname
  end

  def get_project_logo_text(project) do
    slice_name(project.name, 0, 2)
  end

  def get_project_logo(project) do
    if is_nil(project) or is_nil(project.logo) do
      nil
    else
      Snownix.Uploaders.LogoUploader.url({project.logo, project}, :thumb)
    end
  end

  defp slice_name(nil, _index, _size), do: "-"

  defp slice_name(name, index, size) do
    String.slice(name, index, size)
  end
end
