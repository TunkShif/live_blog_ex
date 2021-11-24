defmodule LiveBlogEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveBlogExWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveBlogEx.PubSub},
      # Start the Endpoint (http/https)
      LiveBlogExWeb.Endpoint,
      # Start a worker by calling: LiveBlogEx.Worker.start_link(arg)
      # {LiveBlogEx.Worker, arg}
      LiveBlogEx.Blog
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveBlogEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveBlogExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
