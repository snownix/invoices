defmodule SnownixWeb.SharedLive.Sidebar.UserSidebarComponent do
  use SnownixWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:menu_open, false)}
  end

  def handle_event("menu_open", _, socket) do
    {:noreply, socket |> assign(:menu_open, !socket.assigns.menu_open)}
  end

  def render(assigns) do
    ~H"""
      <nav class="sidebar">
          <div class="sidebar__container">
                <!-- user -->
                <%= render_profile_menu(assigns) %>

                <!-- menu -->
                <%= render_menus(assigns) %>

                <!-- down menu -->
                <%= render_settings_menu(assigns) %>
          </div>
      </nav>
    """
  end

  def render_menus(assigns) do
    ~H"""
    <div class="flex flex-col w-full space-y-6">
      <ul class="sidebar__menu">
        <li>
          <%= live_redirect to: Routes.project_index_path(@socket, :index) do %>
            <span><%= render SnownixWeb.IconsView, "notification.svg", %{} %></span>
            <div>
              <span>Projects</span>
            </div>
          <% end %>
        </li>
        <li>
            <%= live_redirect to: Routes.account_settings_path(@socket, :settings) do %>
              <span><%= render SnownixWeb.IconsView, "settings.svg", %{} %></span>
              <div>
                <span>Settings</span>
              </div>
            <% end %>
          </li>
      </ul>
    </div>
    """
  end

  def render_settings_menu(assigns) do
    ~H"""
    <div class="flex flex-col w-full flex-grow justify-end">
      <ul class="sidebar__menu">
          <li>
            <%= link to: Routes.user_session_path(@socket, :delete), method: :delete, data: [confirm: "Are you sure?"] do %>
              <span><%= render SnownixWeb.IconsView, "logout.svg", %{} %></span>
              <div>
                <span>Logout</span>
              </div>
            <% end %>
          </li>
        </ul>
    </div>
    """
  end

  def render_profile_menu(assigns) do
    ~H"""
    <div
      class="flex flex-col  md:flex-row w-full items-center cursor-pointe cursor-pointer"
      phx-click="menu_open" phx-target={@myself}>
        <div class="flex flex-shrink-0 items-center justify-center duration-100
            hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
          <%= render_user_avatar(assigns, @current_user) %>
        </div>
        <div class="px-2 text-sm w-full">
            <h4 class="font-bold text-dark"><%= get_user_fullname(@current_user) %></h4>
            <p class="text-gray-500 text-sm"><%= @current_user.email %></p>
        </div>
    </div>
    """
  end
end
