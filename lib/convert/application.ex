defmodule Convert.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ConvertWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Convert.PubSub},
      # Start the Endpoint (http/https)
      ConvertWeb.Endpoint
      # Start a worker by calling: Convert.Worker.start_link(arg)
      # {Convert.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Convert.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ConvertWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
