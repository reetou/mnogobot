defmodule MnogobotDiscord do
  @moduledoc """
  Documentation for `MnogobotDiscord`.
  """

  require Logger
  use Application
  alias MnogobotDiscord.Actions.Say
  alias MnogobotDiscord.Actions.Reply
  alias MnogobotDiscord.Actions.Image
  alias Mnogobot.Api
  alias Mnogobot.Dialog

  @impl true
  def start(_type, _args) do
    bot_config =
      Application.fetch_env!(:mnogobot_discord, :bot_config_path)
      |> File.read!()
      |> Jason.decode!()
    dialogs_cfg =
      bot_config
      |> Map.fetch!("data")
      |> Enum.map(fn dialog ->
        %Dialog{}
        |> Dialog.changeset(dialog)
        |> Dialog.format()
      end)
      |> IO.inspect(label: "Dialogs are")
    :ok = Application.put_env(:mnogobot_discord, :dialogs, dialogs_cfg)
    :ets.new(:states, [:set, :public, :named_table])
    children = [
      MnogobotDiscord.ConsumerSupervisor,
    ]
    options = [strategy: :rest_for_one, name: MnogobotDiscord.Supervisor]
    Supervisor.start_link(children, options)
  end

  def actions_mappings do
    %{
      "say" => Say,
      "sticker" => Say,
      "ask" => Say,
      "reply" => Reply,
      "image" => Image
    }
  end

  def dialogs do
    Application.fetch_env!(:mnogobot_discord, :dialogs)
  end
end
