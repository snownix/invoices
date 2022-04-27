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
    String.at(user.firstname, 0) <> String.at(user.lastname, 0)
  end

  def get_user_fullname(user) do
    user.firstname <> " " <> user.lastname
  end

  def get_project_logo_text(project) do
    String.slice(project.name, 0, 2)
  end

  def get_project_logo(project) do
    if is_nil(project) or is_nil(project.logo) do
      nil
    else
      Snownix.Uploaders.LogoUploader.url({project.logo, project}, :thumb)
    end
  end
end
