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
      get_avatar_text(get_user_fullname(user))
    else
      get_avatar_text(user.contact_name)
    end
  end

  def get_user_fullname(user) do
    "#{user.firstname} #{user.lastname}"
  end

  def get_project_logo_text(project) do
    get_avatar_text(project.name)
  end

  def get_project_logo(project) do
    if is_nil(project) or is_nil(project.logo) do
      nil
    else
      Snownix.Uploaders.LogoUploader.url({project.logo, project}, :thumb)
    end
  end

  def get_avatar_text(text) do
    if is_nil(text) do
      ""
    else
      if String.contains?(text, " ") do
        String.split(text, " ")
        |> Enum.map(&String.upcase(slice_name(&1, 0, 1)))
        |> Enum.slice(0, 2)
        |> Enum.join("")
      else
        slice_name(text, 0, 2)
      end
    end
  end

  defp slice_name(nil, _index, _size), do: "-"

  defp slice_name(name, index, size) do
    String.slice(name, index, size)
  end
end
