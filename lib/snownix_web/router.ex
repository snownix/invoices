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

        live "/invoices", InvoiceLive.Index, :index
        live "/settings", SettingsLive.Index, :settings
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

        live "/projects", ProjectLive.Index, :index
        live "/projects/new", ProjectLive.Index, :new
        live "/projects/:id/edit", ProjectLive.Index, :edit

        live "/projects/:id", ProjectLive.Show, :show
        live "/projects/:id/show/edit", ProjectLive.Show, :edit

        live "/taxs", TaxLive.Index, :index
        live "/taxs/new", TaxLive.Index, :new
        live "/taxs/:id/edit", TaxLive.Index, :edit

        live "/taxs/:id", TaxLive.Show, :show
        live "/taxs/:id/show/edit", TaxLive.Show, :edit

        live "/customer_users", UserLive.Index, :index
        live "/customer_users/new", UserLive.Index, :new
        live "/customer_users/:id/edit", UserLive.Index, :edit

        live "/customer_users/:id", UserLive.Show, :show
        live "/customer_users/:id/show/edit", UserLive.Show, :edit
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
