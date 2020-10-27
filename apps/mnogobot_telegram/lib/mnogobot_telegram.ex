defmodule MnogobotTelegram do
  @moduledoc """
  Documentation for `MnogobotTelegram`.
  """

  use Application
  alias MnogobotTelegram.Matcher
  alias MnogobotTelegram.Poller
  alias Mnogobot.Dialog
  alias Mnogobot.Api
  alias MnogobotTelegram.Actions.Say
  alias MnogobotTelegram.Actions.Reply
  alias MnogobotTelegram.Actions.Image

  @impl true
  def start(_type, _args) do
    bot_config =
      Application.fetch_env!(:mnogobot_telegram, :bot_config_path)
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
    :ok = Application.put_env(:mnogobot_telegram, :dialogs, dialogs_cfg)
    :ets.new(:states, [:set, :public, :named_table])
    children = [
      Poller,
      Matcher,
    ]
    options = [strategy: :rest_for_one, name: MnogobotTelegram.Supervisor]
    Supervisor.start_link(children, options)
  end

  def actions_mappings do
    %{
      "say" => Say,
      "ask" => Say,
      "reply" => Reply,
      "image" => Image,
      "sticker" => Say
    }
  end

  def dialogs do
    Application.fetch_env!(:mnogobot_telegram, :dialogs)
    |> IO.inspect(label: "Dialogs from telegram")
  end
end
