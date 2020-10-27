defmodule MnogobotDiscord.ConsumerSupervisor do
  @moduledoc """
  Supervises bot consumers.
  Bot spawns one consumer per online scheduler at startup,
  which means one consumer per CPU core in the default ERTS settings.

  Copied from bolt project
  """

  use Supervisor
  require Logger

  def start_link(args) do
    Logger.debug("Starting consumer supervisor")
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    System.schedulers_online()
    |> IO.inspect(label: "Schedulers in total")
    children =
      for n <- 1..System.schedulers_online() do
#        IO.inspect(n, label: "Starting Bot.Consumer for scheduler")
        Supervisor.child_spec({MnogobotDiscord.Consumer, []}, id: {:bot, :consumer, n})
      end
    Supervisor.init(children, strategy: :one_for_one)
  end
end
