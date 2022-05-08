defmodule SnownixWeb.IndexLive.Design do
  use SnownixWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="space-y-4 divide-y">
      <h1 class="font-bold">Design System</h1>

      <div class=" py-4 grid grid-cols-1 lg:grid-cols-2 gap-10 md:justify-between">

        <section class="buttons divide-y w-full space-y-5">
          <h2 class="font-semibold">Form</h2>
          <div class="py-4 grid grid-cols-2 gap-4 items-center">
            <div><input placeholder="Basic ..."></div>
            <div><input placeholder="Disabled" disabled></div>
            <div><input placeholder="Info" class="info"></div>
            <div><input placeholder="Error" class="error"></div>
            <div><select><option>Basic</option></select></div>
            <div><select class="error"><option>Error</option></select></div>
            <div><input type="date" placeholder="Date"></div>
            <div><input type="date" placeholder="Invalid" class="error"></div>
            <div><textarea placeholder="Basic"></textarea></div>
            <div><textarea placeholder="Error" class="error"></textarea></div>
            <div>
              <input type="checkbox" id="cbox-1">
              <label for="cbox-1">Checkbox</label>
            </div>
            <div>
              <input type="checkbox" disabled id="cbox-2">
              <label for="cbox-2">Disabled</label>
            </div>
            <div>
              <input type="radio" id="rad-1">
              <label for="rad-1">Radiobox</label>
            </div>
             <div>
              <input type="radio" disabled id="rad-2">
              <label for="rad-2">Disabled</label>
            </div>
            <label class="switch">
              <input type="checkbox">
              <span class="slider round"></span>
            </label>
          </div>
        </section>

        <section class="colors divide-y w-full space-y-5">
          <h2 class="font-semibold">Colors</h2>
          <div class="py-4 grid grid-cols-2 gap-2">
            <div class="p-2 rounded-lg border flex items-center"><div class="mr-3 rounded-lg bg-primary w-10 h-10"></div>Primary</div>
            <div class="p-2 rounded-lg border flex items-center"><div class="mr-3 rounded-lg bg-secondary w-10 h-10"></div>Secondary</div>
            <div class="p-2 rounded-lg border flex items-center"><div class="mr-3 rounded-lg bg-dark w-10 h-10"></div>Dark</div>
            <div class="p-2 rounded-lg border flex items-center"><div class="mr-3 rounded-lg border bg-light w-10 h-10"></div>Light</div>
            <div class="p-2 rounded-lg border flex items-center"><div class="mr-3 rounded-lg border bg-red-500 w-10 h-10"></div>Red</div>
            <div class="p-2 col-span-2 flex flex-col rounded-lg border flex items-center">
              <label>Gray</label>
              <div class="flex flex-wrap space-x-2">
                <div class="rounded-lg border bg-gray-50 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-100 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-200 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-300 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-400 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-500 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-600 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-700 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-800 w-6 h-6"></div>
                <div class="rounded-lg border bg-gray-900 w-6 h-6"></div>
              </div>
            </div>
          </div>
        </section>

        <section class="typographys divide-y w-full space-y-5">
          <h2 class="font-semibold">Typography</h2>
          <div class="py-4 grid grid-cols-1 items-center gap-4">
            <h1>Content</h1>
            <h2>Content</h2>
            <h3>Content</h3>
            <h4>Content</h4>
            <h5>Content</h5>
            <p>Paragraph</p>
            <a target="_blank" href="https://github.com">Link</a>
          </div>
        </section>

        <section class="buttons divide-y w-full space-y-5">
          <h2 class="font-semibold">Buttons</h2>
          <div class="py-4 grid grid-cols-2 gap-4 items-center">
            <div><button>Basic</button></div>
            <div><button disabled>Disabled</button></div>
            <div><button class="dark">Dark</button></div>
            <div><button class="primary">Primary</button></div>
          </div>
        </section>

        <section class="icons divide-y w-full space-y-5">
          <h2 class="font-semibold">Icons</h2>
          <div class="py-4 grid grid-cols-3 lg:grid-cols-5 gap-4">
            <div><%= render SnownixWeb.IconsView, "cancel.svg", %{} %><span>Cancel</span></div>
            <div><%= render SnownixWeb.IconsView, "categories.svg", %{} %><span>Categories</span></div>
            <div><%= render SnownixWeb.IconsView, "customers.svg", %{} %><span>Customers</span></div>
            <div><%= render SnownixWeb.IconsView, "help.svg", %{} %><span>Help</span></div>
            <div><%= render SnownixWeb.IconsView, "invoices.svg", %{} %><span>Invoices</span></div>
            <div><%= render SnownixWeb.IconsView, "logout.svg", %{} %><span>Logout</span></div>
            <div><%= render SnownixWeb.IconsView, "notification.svg", %{} %><span>Notification</span></div>
            <div><%= render SnownixWeb.IconsView, "products.svg", %{} %><span>Products</span></div>
            <div><%= render SnownixWeb.IconsView, "quotes.svg", %{} %><span>Quotes</span></div>
            <div><%= render SnownixWeb.IconsView, "save.svg", %{} %><span>Save</span></div>
            <div><%= render SnownixWeb.IconsView, "search.svg", %{} %><span>Search</span></div>
            <div><%= render SnownixWeb.IconsView, "security.svg", %{} %><span>Security</span></div>
            <div><%= render SnownixWeb.IconsView, "send.svg", %{} %><span>Send</span></div>
            <div><%= render SnownixWeb.IconsView, "settings.svg", %{} %><span>Settings</span></div>
            <div><%= render SnownixWeb.IconsView, "upload.svg", %{} %><span>Upload</span></div>
          </div>
        </section>

      </div>
    </section>
    """
  end
end
