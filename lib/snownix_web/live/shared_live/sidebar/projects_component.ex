defmodule SnownixWeb.SharedLive.Sidebar.ProjectsComponent do
  use SnownixWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex flex-col relative -ml-2 -mr-2">
      <div class="absolute  w-full top-2 bg-white space-y-2 px-3 py-4 border rounded-xl shadow-md z-30">
        <%= render_project(assigns) %>
        <%= render_project(assigns) %>
        <%= render_project(assigns) %>
        <%= render_project(assigns) %>
      </div>
    </div>
    """
  end

  def render_project(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row w-full items-center cursor-pointer">
      <div class="text-gray-500">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-4" fill="none" viewBox="12 0 12 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
        </svg>
      </div>
      <div class="flex flex-shrink-0 items-center justify-center bg-purple-500 duration-100
            hover:ring-4 hover:ring-offset-2 hover:ring-dark hover:ring-opacity-30 rounded-xl w-10 h-10">
             <span class="text-light font-bold ">FR</span>
      </div>
      <div class="px-4 text-sm w-full">
          <h3 class="font-bold text-dark">Unik</h3>
          <p class="text-gray-500">Bronze Plan</p>
      </div>
      <div class="text-gray-400">
      </div>
    </div>
    """
  end
end
