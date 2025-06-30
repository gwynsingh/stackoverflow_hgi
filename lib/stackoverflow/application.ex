defmodule Stackoverflow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StackoverflowWeb.Telemetry,
      Stackoverflow.Repo,
      {DNSCluster, query: Application.get_env(:stackoverflow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Stackoverflow.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Stackoverflow.Finch},
      # Start a worker by calling: Stackoverflow.Worker.start_link(arg)
      # {Stackoverflow.Worker, arg},
      # Start to serve requests, typically the last entry
      StackoverflowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stackoverflow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StackoverflowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
