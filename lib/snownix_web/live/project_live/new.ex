defmodule SnownixWeb.ProjectLive.New do
  use SnownixWeb, :live_dashboard

  import Snownix.Geo
  alias Snownix.Organization
  alias Snownix.Organization.Project

  @situtations [
    %{
      id: "freelance",
      icon: "settings",
      description: "You are a freelancer or independent contractor."
    },
    %{
      id: "company",
      icon: "settings",
      description: "You have a registred company"
    }
  ]

  @steps [
    %{
      title: "Tell us your project situation"
    },
    %{
      title: "Project information",
      prev: true
    }
  ]

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(step: 1, situation: "company")
     |> assign_changeset()
     |> assign(situtations: @situtations, steps: @steps)}
  end

  def assign_changeset(socket) do
    socket |> assign(:changeset, Organization.change_project(%Project{}))
  end

  def handle_event("validate", %{"project" => params}, socket) do
    changeset =
      %Project{}
      |> Organization.change_project(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    user = socket.assigns.current_user

    params = Map.merge(project_params, %{"situation" => socket.assigns.situation})

    case Organization.create_project(user, params) do
      {:ok, project} ->
        {
          :noreply,
          socket
          |> put_flash(:success, "Project #{project.id} created successfully")
          |> redirect(to: Routes.project_index_path(socket, :index))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> put_changeset_errors(changeset) |> assign(:changeset, changeset)}
    end
  end

  def handle_event("situation", params, socket) do
    %{"situation" => situation} = params

    if @situtations |> Enum.find(&(&1.id == situation)) do
      {:noreply,
       socket
       |> assign(:step, 1)
       |> assign(:situation, situation)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next", _, socket) do
    case get_step(socket.assigns.step) do
      %{next: true} ->
        {:noreply, socket |> assign(:step, 1 + socket.assigns.step)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("prev", _, socket) do
    case get_step(socket.assigns.step) do
      %{prev: true} ->
        {:noreply, socket |> assign(:step, socket.assigns.step - 1)}

      _ ->
        {:noreply, socket}
    end
  end

  def get_step(index) do
    Enum.at(@steps, index)
  end

  def is_step(assigns, index), do: assigns.step == index
end
