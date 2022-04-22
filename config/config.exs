# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :snownix,
  ecto_repos: [Snownix.Repo]

# Configures the endpoint
config :snownix, SnownixWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: SnownixWeb.ErrorView,
    accepts: ~w(html json),
    layout: {SnownixWeb.LayoutView, "root.html"}
  ],
  pubsub_server: Snownix.PubSub,
  live_view: [signing_salt: "y77EDEzc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :snownix, Snownix.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.0.23",
  default: [
    args: ~w(
    --postcss
    --config=../assets/tailwind.config.js
    --input=../assets/css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Default en
config :snownix, SnownixWeb.Gettext,
  default_locale: "en",
  locales: ~w(en fr)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
