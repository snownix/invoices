defmodule SnownixWeb.SharedLive.SidebarComponent do
  use SnownixWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:menu_open, false)}
  end

  def handle_event("menu_open", _, socket) do
    {:noreply, socket |> assign(:menu_open, !socket.assigns.menu_open)}
  end

  def render(assigns) do
    ~H"""
      <nav aria-label="Sidebar" class="hidden md:block md:flex-shrink-0 md:bg-white md:overflow-y-auto border-r">
          <div class="flex flex-col h-full lg:w-72 relative space-y-8 py-6 px-4 items-stretch">
                <!-- logo -->
                <%= render_project_menu(assigns) %>

                <!-- search -->
                <%= render_search(assigns) %>

                <!-- menu -->
                <%= render_menus(assigns) %>

                <!-- down menu -->
                <%= render_settings_menu(assigns) %>

                <!-- profile -->
                <%= render_profile_menu(assigns) %>
          </div>
          <%= if @menu_open do %>
            <%= render_profile_nav(assigns) %>
          <% end %>
      </nav>
    """
  end

  def render_project_menu(assigns) do
    ~H"""
    <div>
      <div class="flex flex-col md:flex-row w-full items-center cursor-pointer">
          <div class="flex flex-shrink-0 items-center justify-center bg-primary duration-100
              hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
              <span class="text-light font-bold ">NA</span>
          </div>
          <div class="px-4 text-sm w-full">
              <h3 class="font-bold text-dark">Neutrapp</h3>
              <p class="text-gray-500">Free Plan</p>
          </div>
          <div class="text-gray-400 hidden">
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
                   <path
                       d="M12 5.83L15.17 9l1.41-1.41L12 3 7.41 7.59 8.83 9 12 5.83zm0 12.34L8.83 15l-1.41 1.41L12 21l4.59-4.59L15.17 15 12 18.17z" />
               </svg>
          </div>
        </div>
    </div>
    """
  end

  def render_search(assigns) do
    ~H"""
    <div class="w-full">
        <%= form_for :user, "#", [phx_submit: "submit"], fn f -> %>
            <div class="flex relative items-center text-gray-400">
                <span class="absolute px-3">
                  <%= render SnownixWeb.IconsView, "search.svg", %{} %>
                </span>
                <%= text_input f, :query, placeholder: gettext("Search ..."), class: "pl-10 bg-gray-50 border-2 border-opacity-40 placeholder:text-gray-400", "tab-index": 1 %>
              </div>
        <% end %>
    </div>
    """
  end

  def render_menus(assigns) do
    ~H"""
    <div class="flex flex-col w-full space-y-6">
      <ul class="sidebar__menu">
        <li>
          <a href="/">
            <%= render SnownixWeb.IconsView, "notification.svg", %{} %>
            <span>Activity</span>
          </a>
        </li>
        <li>
          <a href="/">
            <%= render SnownixWeb.IconsView, "invoices.svg", %{} %>
            <span>Invoices</span>
          </a>
        </li>
        <li>
          <a href="/">
            <%= render SnownixWeb.IconsView, "quotes.svg", %{} %>
            <span>Quotes</span>
          </a>
        </li>
      </ul>

      <div class="w-full px-2">
        <div class="border-b border-dark border-opacity-10 w-full"></div>
      </div>
      <div class="flex flex-col">
        <p class="mb-2 text-dark font-semibold text-sm px-2 text-gray-400">
          Advanced
        </p>
        <ul class="sidebar__menu">
          <li>
            <a href="/">
              <%= render SnownixWeb.IconsView, "clients.svg", %{} %>
              <span>Clients</span>
            </a>
            </li>
          <li>
            <a href="/">
              <%= render SnownixWeb.IconsView, "products.svg", %{} %>
              <span>Products</span>
            </a>
            </li>
            <li>
            <a href="/">
              <%= render SnownixWeb.IconsView, "categories.svg", %{} %>
              <span>Categories</span>
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def render_settings_menu(assigns) do
    ~H"""
    <div class="flex flex-col w-full flex-grow justify-end">
      <ul class="sidebar__menu">
          <li>
            <a href="/">
              <%= render SnownixWeb.IconsView, "settings.svg", %{} %>
              <span>Settings</span>
            </a>
          </li>
          <li>
            <a href="/">
              <%= render SnownixWeb.IconsView, "help.svg", %{} %>
              <span>Help</span>
            </a>
          </li>
        </ul>
    </div>
    """
  end

  def render_profile_menu(assigns) do
    ~H"""
    <div class="relative">
      <div class="w-full border-b border-dark border-opacity-20 mb-5"></div>
      <div
        class="flex flex-col md:flex-row w-full items-center cursor-pointe cursor-pointer"
        phx-click="menu_open" phx-target={@myself}>
          <div class="flex flex-shrink-0 items-center justify-center duration-100
              hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
            <%= render_avatar(assigns, @current_user) %>
          </div>
          <div class="px-2 text-sm w-full">
              <h3 class="font-bold text-dark"><%= get_user_fullname(@current_user) %></h3>
              <p class="text-gray-500 text-sm"><%= @current_user.email %></p>
          </div>
          <div class="text-gray-400">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
                  <path
                      d="M12 5.83L15.17 9l1.41-1.41L12 3 7.41 7.59 8.83 9 12 5.83zm0 12.34L8.83 15l-1.41 1.41L12 21l4.59-4.59L15.17 15 12 18.17z" />
              </svg>
          </div>
      </div>
    </div>
    """
  end

  def render_profile_nav(assigns) do
    ~H"""
    <div
      class="absolute flex flex-col min-w-56 p-4 space-y-2 bg-white border z-20 shadow rounded-lg bottom-2 lg:left-72 lg:ml-2"
      phx-click="menu_open" phx-target={@myself}>

      <div class="fixed inset-0 w-full h-full z-20 bg-gray-100 bg-opacity-50 duration-1000"></div>
      <div class="flex flex-col z-30 md:flex-row w-full items-center cursor-pointer border-b pb-3">
          <div class="flex flex-shrink-0 items-center justify-center duration-100
              hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
            <%= render_avatar(assigns, @current_user) %>
          </div>
          <div class="pl-2 text-sm w-full">
              <h3 class="font-bold text-dark"><%= get_user_fullname(@current_user) %></h3>
              <p class="text-gray-500 text-sm"><%= @current_user.email %></p>
          </div>
      </div>
      <ul class="sidebar__menu z-30">
          <li>
            <%= live_redirect to: Routes.account_settings_path(@socket, :settings) do %>
              <%= render SnownixWeb.IconsView, "settings.svg", %{} %>
              <span>Settings</span>
            <% end %>
          </li>
          <li class="mt-4">
            <a href="/">
              <%= render SnownixWeb.IconsView, "logout.svg", %{} %>
              <span>Logout</span>
            </a>
          </li>
      </ul>
      <div class="text-xs text-gray-400 px-2">v1.5.69 • Terms & Conditions</div>
    </div>
    """
  end

  def render_avatar(assigns, user) do
    ~H"""
      <%= if is_nil(get_user_avatar(user)) do %>
          <div class="w-10 h-10 avatar__text !text-base"><%= get_user_avatar_text(user) %></div>
      <% else %>
          <img src={get_user_avatar(user)} class="avatar w-10 h-10">
      <% end %>
    """
  end
end
