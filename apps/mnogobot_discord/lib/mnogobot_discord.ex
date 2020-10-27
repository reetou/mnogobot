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
    dialogs =
      bot_config
      |> Map.fetch!("data")
      |> Enum.map(fn dialog ->
        %Dialog{}
        |> Dialog.changeset(dialog)
        |> Dialog.format()
      end)
      |> IO.inspect(label: "Dialogs are")
    :ok = Application.put_env(:mnogobot_discord, :dialogs, dialogs)
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

  def get_action_module(%{action: action}) do
    Map.get(actions_mappings(), action, :ignore)
  end

  def trigger_action(action, state, msg) do
    action
    |> get_action_module()
    |> execute_action(Api.parse_action_args(action, state), msg)
  end

  def trigger_dialog(state, %{} = msg) do
    state
    |> Api.current_action()
    |> trigger_action(state, msg)
  end

  def dialogs do
    Application.fetch_env!(:mnogobot_discord, :dialogs)
  end

  defp execute_action(:ignore, _, _), do: :ignore
  defp execute_action(module, parsed_args, msg) do
    module.execute(parsed_args, msg)
  end
end
