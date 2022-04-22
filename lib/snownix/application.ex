defmodule Snownix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Snownix.Repo,
      # Start the Telemetry supervisor
      SnownixWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Snownix.PubSub},
      # Cache Service
      {Cachex, name: :snownix},
      # Start the Endpoint (http/https)
      SnownixWeb.Endpoint
      # Start a worker by calling: Snownix.Worker.start_link(arg)
      # {Snownix.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Snownix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SnownixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
