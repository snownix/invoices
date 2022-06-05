defmodule SnownixWeb.Router do
  use SnownixWeb, :router

  import SnownixWeb.UserAuth
  import SnownixWeb.Project

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SnownixWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug SnownixWeb.Plugs.SetLocale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :project do
    plug :browser
    plug :require_authenticated_user
    plug :fetch_current_project
    plug :required_project
  end

  ## Dashboards
  live_session :project,
    on_mount: [
      {SnownixWeb.InitAssigns, :user},
      {SnownixWeb.InitAssigns, :project}
    ] do
    scope "/", SnownixWeb do
      pipe_through [:project]

      live "/", ProjectLive.Dashboard, :index

      scope "/org", Org, as: :org do
        scope "/customers" do
          live "/", CustomerLive.Index, :index
          live "/new", CustomerLive.Index, :new
          live "/:id", CustomerLive.Index, :show
          live "/:id/edit", CustomerLive.Index, :edit
        end

        scope "/categories" do
          live "/", CategoryLive.Index, :index
          live "/new", CategoryLive.Index, :new
          live "/:id", CategoryLive.Index, :show
          live "/:id/edit", CategoryLive.Index, :edit
        end

        scope "/products" do
          live "/", ProductLive.Index, :index
          live "/new", ProductLive.Index, :new
          live "/:id", ProductLive.Index, :show
          live "/:id/edit", ProductLive.Index, :edit
        end

        live "/invoices", InvoiceLive.Index, :index
        live "/settings", SettingsLive.Index, :settings

        live "/activities", ActivityLive.Index, :index
      end
    end
  end

  ## Liveview routes
  live_session :default,
    on_mount: [{SnownixWeb.InitAssigns, :user}, {SnownixWeb.InitAssigns, :project}] do
    scope "/", SnownixWeb do
      pipe_through [:browser]

      # Public
      live "/design", IndexLive.Design, :index

      scope "/account" do
        live "/confirm", AuthLive.Reconfirm, :reconfirm
        live "/confirm/:token", AuthLive.Confirm, :confirm
      end

      # User
      scope "/" do
        pipe_through [:require_authenticated_user]

        scope "/projects" do
          live "/", ProjectLive.Index, :index
          live "/new", ProjectLive.New, :new

          get "/open/:id", ProjectController, :open
          get "/leave", ProjectController, :leave
        end

        live "/account/settings", AccountLive.Settings, :settings
      end

      # Admin
      scope "/admin", Admin, as: :admin do
        pipe_through [:require_authenticated_user]

        # Activities

        scope "/activities" do
          live "/", ActivityLive.Index, :index
          live "/new", ActivityLive.Index, :new
          live "/:id/edit", ActivityLive.Index, :edit

          live "/:id", ActivityLive.Show, :show
          live "/:id/show/edit", ActivityLive.Show, :edit
        end

        # Products
        scope "/products" do
          live "/", ProductLive.Index, :index
          live "/new", ProductLive.Index, :new
          live "/:id/edit", ProductLive.Index, :edit

          live "/:id", ProductLive.Show, :show
          live "/:id/show/edit", ProductLive.Show, :edit
        end

        # Units
        scope "/units" do
          live "/", UnitLive.Index, :index
          live "/new", UnitLive.Index, :new
          live "/:id/edit", UnitLive.Index, :edit

          live "/:id", UnitLive.Show, :show
          live "/:id/show/edit", UnitLive.Show, :edit
        end

        # Category
        scope "/categories" do
          live "/", CategoryLive.Index, :index
          live "/new", CategoryLive.Index, :new
          live "/:id/edit", CategoryLive.Index, :edit

          live "/:id", CategoryLive.Show, :show
          live "/:id/show/edit", CategoryLive.Show, :edit
        end

        # Projects
        scope "/projects" do
          live "/", ProjectLive.Index, :index
          live "/new", ProjectLive.Index, :new
          live "/:id/edit", ProjectLive.Index, :edit

          live "/:id", ProjectLive.Show, :show
          live "/:id/show/edit", ProjectLive.Show, :edit
        end

        # Taxs
        scope "/taxs" do
          live "/", TaxLive.Index, :index
          live "/new", TaxLive.Index, :new
          live "/:id/edit", TaxLive.Index, :edit

          live "/:id", TaxLive.Show, :show
          live "/:id/show/edit", TaxLive.Show, :edit
        end

        # Customers
        scope "/customer_users" do
          live "/", UserLive.Index, :index
          live "/new", UserLive.Index, :new
          live "/:id/edit", UserLive.Index, :edit

          live "/:id", UserLive.Show, :show
          live "/:id/show/edit", UserLive.Show, :edit
        end

        # Address
        scope "/addresses" do
          live "/", AddressLive.Index, :index
          live "/new", AddressLive.Index, :new
          live "/:id/edit", AddressLive.Index, :edit

          live "/:id", AddressLive.Show, :show
          live "/:id/show/edit", AddressLive.Show, :edit
        end
      end

      # Auth
      scope "/auth" do
        pipe_through [:redirect_if_user_is_authenticated]

        live "/login", AuthLive.Login, :login
        live "/register", AuthLive.Register, :register
        live "/forgot-password", AuthLive.ForgotPassword, :forgot
        live "/reset-password/:token", AuthLive.ResetPassword, :reset
      end
    end
  end

  ## Controllers
  scope "/auth", SnownixWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete
  end

  scope "/auth", SnownixWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    post "/login", UserSessionController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", SnownixWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL  which you should anyway.
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: SnownixWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
