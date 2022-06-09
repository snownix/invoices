defmodule SnownixWeb.SharedLive.Sidebar.ProjectSidebarComponent do
  use SnownixWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(:menu_open, false)}
  end

  def handle_event("menu_open", _, socket) do
    {:noreply, socket |> assign(:menu_open, !socket.assigns.menu_open)}
  end

  def render(assigns) do
    ~H"""
      <nav class="sidebar" phx-hook="Sidebar" id="project-sidebar">
          <div class="sidebar__container">
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
          <%= render_project_logo(assigns, @project, " w-12 h-12 ") %>
          <div class="inmini__hide px-2 text-sm w-full">
              <h4 class="font-bold"><%= @project.name %></h4>
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
    <div class="sidebar__search">
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
        <li phx-hook="ShortCut" data-key="1" data-target-el="#nav-activity" id="sk-nav-activity">
          <%= live_patch to: Routes.org_activity_index_path(@socket, :index), id: "nav-activity" do %>
            <div>
              <%= render SnownixWeb.IconsView, "notification.svg", %{} %>
              <span><%= gettext("Activity") %></span>
            </div>
            <div class="_shortkey">
              <%= render SnownixWeb.IconsView, "cmd.svg" , %{} %>
              <span>1</span>
            </div>
          <% end %>
        </li>
        <li phx-hook="ShortCut" data-key="2" data-target-el="#nav-invoices" id="sk-nav-invoices">
          <%= live_patch to: Routes.org_invoice_index_path(@socket, :index), id: "nav-invoices" do %>
            <div>
              <%= render SnownixWeb.IconsView, "invoices.svg", %{} %>
              <span><%= gettext("Invoices") %></span>
            </div>
            <div class="_shortkey">
              <%= render SnownixWeb.IconsView, "cmd.svg" , %{} %>
              <span>2</span>
            </div>
          <% end %>
        </li>
        <li phx-hook="ShortCut" data-key="3" data-target-el="#nav-quotes" id="sk-nav-quotes">
          <a href="/" id="nav-quotes">
            <div>
              <%= render SnownixWeb.IconsView, "quotes.svg", %{} %>
              <span><%= gettext("Quotes") %></span>
            </div>
            <div class="_shortkey">
              <%= render SnownixWeb.IconsView, "cmd.svg" , %{} %>
              <span>3</span>
            </div>
          </a>
        </li>
      </ul>

      <div class="w-full px-2">
        <div class="border-b border-dark border-opacity-10 w-full"></div>
      </div>
      <div class="flex flex-col">
        <p class="sidebar__group">
          <%= gettext "Advanced" %>
        </p>
        <ul class="sidebar__menu">
          <li>
            <%= live_patch to: Routes.org_customer_index_path(@socket, :index) do %>
              <div>
                <%= render SnownixWeb.IconsView, "customers.svg", %{} %>
                <span><%= gettext("Customers") %></span>
              </div>
            <% end %>
            </li>
          <li>
            <%= live_patch to: Routes.org_product_index_path(@socket, :index) do %>
              <div>
              <%= render SnownixWeb.IconsView, "products.svg", %{} %>
                <span><%= gettext("Products") %></span>
                </div>
              <% end %>
            </li>
            <li>
            <%= live_patch to: Routes.org_category_index_path(@socket, :index) do %>
              <div>
                <%= render SnownixWeb.IconsView, "categories.svg", %{} %>
                <span><%= gettext("Categories") %></span>
              </div>
              <% end %>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def render_settings_menu(assigns) do
    ~H"""
    <div class="flex flex-col w-full flex-grow !justify-end">
      <ul class="sidebar__menu">
          <li class="btn__minimize">
            <a href="javascript:void(0)" >
              <div>
                <%= render SnownixWeb.IconsView, "minimize.svg", %{} %>
                <span><%= gettext("Toggle Sidebar") %></span>
              </div>
            </a>
          </li>
          <li>
            <%= live_redirect to: Routes.org_settings_index_path(@socket, :settings) do %>
              <div>
                <%= render SnownixWeb.IconsView, "settings.svg", %{} %>
                <span><%= gettext("Settings") %></span>
              </div>
              <% end %>
          </li>
          <li>
            <%= live_redirect to: Routes.project_path(@socket, :leave) do %>
              <div>
              <%= render SnownixWeb.IconsView, "leave.svg", %{} %>
              <span><%= gettext("Leave") %></span>
              </div>
              <% end %>
          </li>
        </ul>
    </div>
    """
  end

  def render_profile_menu(assigns) do
    ~H"""
    <div>
    <div class="w-full border-b border-dark border-opacity-10"></div>
      <div
        class="flex flex-col pt-4 md:flex-row w-full items-center cursor-pointe cursor-pointer"
        phx-click="menu_open" phx-target={@myself}>
          <div class="flex flex-shrink-0 items-center justify-center duration-100
              hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
            <%= render_user_avatar(assigns, @current_user) %>
          </div>
          <div class="inmini__hide px-2 text-sm w-full">
              <h4 class="font-bold"><%= get_user_fullname(@current_user) %></h4>
              <p class="text-gray-500 text-sm"><%= @current_user.email %></p>
          </div>
          <div class="inmini__hide text-gray-400">
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
      class="sidebar__profile"
      phx-click="menu_open" phx-target={@myself}>

      <div class="fixed inset-0 w-full h-full z-20"></div>
      <div class="flex flex-col z-30 md:flex-row w-full items-center cursor-pointer border-b pb-3">
          <div class="flex flex-shrink-0 items-center justify-center duration-100
              hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
            <%= render_user_avatar(assigns, @current_user) %>
          </div>
          <div class="pl-2 text-sm w-full">
              <h4 class="font-bold"><%= get_user_fullname(@current_user) %></h4>
              <p class="text-gray-500 text-sm"><%= @current_user.email %></p>
          </div>
      </div>
      <ul class="sidebar__menu z-30">
          <li>
            <%= live_redirect to: Routes.account_settings_path(@socket, :settings) do %>
              <div>
              <%= render SnownixWeb.IconsView, "settings.svg", %{} %>
              <span><%= gettext("Settings") %></span>
              </div>
              <% end %>
          </li>
          <li class="mt-2">
            <%= link to: Routes.user_session_path(@socket, :delete), method: :delete, data: [confirm: "Are you sure?"] do %>
              <div>
                <%= render SnownixWeb.IconsView, "logout.svg", %{} %>
                <span><%= gettext("Logout") %></span>
              </div>
            <% end %>
          </li>
      </ul>
      <!--
      <div class="text-xs text-gray-400 px-2">v1.5.69 • Terms & Conditions</div>
      -->
    </div>
    """
  end
end
