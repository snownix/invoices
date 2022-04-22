defmodule SnownixWeb.AccountLive.Settings do
  use SnownixWeb, :live_dashboard

  alias Snownix.Accounts

  @tabs [
    %{
      title: "Account",
      icon: "settings.svg",
      description:
        "Lorem ipsum dolor sit amet consectetur, adipisicing elit. Facilis omnis similique doloribus, expedita corporis maxime harum voluptatem"
    },
    %{
      title: "Security",
      icon: "security.svg",
      description:
        "Lorem ipsum dolor sit amet consectetur, adipisicing elit. Facilis omnis similique doloribus, expedita corporis maxime harum voluptatem"
    },
    %{
      title: "Notifications",
      icon: "notification.svg",
      description:
        "Lorem ipsum dolor sit amet consectetur, adipisicing elit. Facilis omnis similique doloribus, expedita corporis maxime harum voluptatem"
    }
  ]
  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:tabs, @tabs)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png .gif .txt),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign(:tab, select_tab())
     |> assign(:changeset, socket.assigns.current_user |> Accounts.user_changeset(%{}))
     |> assign(
       :security_changeset,
       socket.assigns.current_user |> Accounts.user_password_changeset(%{})
     )}
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(:tab, select_tab(tab))}
  end

  @doc """
  Account changeset
  """
  def handle_event("account-validate", %{"user" => user_params}, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :changeset,
       socket.assigns.current_user
       |> Accounts.user_changeset(user_params)
       |> Map.put(:action, :validate)
     )}
  end

  def handle_event("account-save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    %{"current_password" => password} = user_params

    case Accounts.update_user(user, password, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:changeset, Accounts.user_changeset(user, user_params))
         |> put_flash(:success, gettext("Account information updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  @doc """
  Seucurity changeset
  """
  def handle_event("security-validate", %{"user" => user_params}, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> assign(
       :security_changeset,
       socket.assigns.current_user
       |> Accounts.user_password_changeset(user_params)
       |> Map.put(:action, :validate)
     )}
  end

  def handle_event("security-save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    %{"current_password" => password} = user_params

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:security_changeset, Accounts.user_password_changeset(user, user_params))
         |> put_flash(:success, gettext("Security information updated successfully."))}

      {:error, changeset} ->
        {:noreply, socket |> assign(:security_changeset, changeset)}
    end
  end

  # Avatar
  def handle_event("validate", _, socket), do: {:noreply, socket}

  def handle_event("delete-avatar", _, socket) do
    current_user = socket.assigns.current_user

    if !is_nil(current_user.avatar) do
      Snownix.Uploaders.AvatarUploader.delete({current_user.avatar, current_user})
    end

    case Accounts.update_user_avatar(current_user, nil) do
      {:ok, user} ->
        {:noreply, socket |> assign(:current_user, user)}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_progress(:avatar, entry, socket) do
    if entry.done? do
      current_user = socket.assigns.current_user

      consume_uploaded_entries(socket, :avatar, fn meta, entry ->
        {:ok, user} =
          Accounts.update_user_avatar(current_user, %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          })

        {:ok, Snownix.Uploaders.AvatarUploader.url({user.avatar, user}, :original)}
      end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Tabs
  defp select_tab(tab \\ nil) do
    Enum.find(@tabs, List.first(@tabs), &(&1.title == tab))
  end

  def is_active_tab(current, tab) do
    current.title == tab.title
  end

  # Upload messages
  defp error_to_string(:too_large), do: gettext("File size is too large, max allowed 2MB.")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files.")

  defp error_to_string(:not_accepted),
    do: gettext("You have selected an unacceptable file type, only images are accepted.")
end
