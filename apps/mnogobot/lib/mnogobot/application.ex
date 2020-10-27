defmodule Mnogobot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Mnogobot.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mnogobot.PubSub}
      # Start a worker by calling: Mnogobot.Worker.start_link(arg)
      # {Mnogobot.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Mnogobot.Supervisor)
  end
end
