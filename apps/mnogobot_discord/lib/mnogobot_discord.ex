defmodule MnogobotDiscord do
  @moduledoc """
  Documentation for `MnogobotDiscord`.
  """

  require Logger
  use Application
  import Application
  alias MnogobotDiscord.Actions.Say
  alias Mnogobot.Api
  alias Mnogobot.Dialog.Action

  @dialogs []

  @impl true
  def start(_type, _args) do
    children = [
      MnogobotDiscord.ConsumerSupervisor,
    ]
    options = [strategy: :rest_for_one, name: MnogobotDiscord.Supervisor]
    Supervisor.start_link(children, options)
  end

  def actions_mappings do
    %{
      "say" => Say
    }
  end

  def get_action_module(%{action: action}) do
    Map.get(actions_mappings(), action, :ignore)
  end

  def trigger_dialog(dialogs, vars) when is_list(dialogs) do
    Enum.map(dialogs, &trigger_dialog(&1, vars))
  end

  def trigger_dialog(%{actions: [action | t], vars: dialog_vars}, vars) do
    trigger_action(action, vars)
  end

  def trigger_action(action, vars) do
    action
    |> get_action_module()
    |> execute_action(Action.apply_vars(action, vars))
  end

  def trigger_dialog(state, %{content: text}) do
    state
    |> Api.next_state(text)
    |> Api.current_action()
    |> trigger_action(state.vars)
  end

  defp execute_action(module, parsed_args) do
    module.execute(parsed_args)
  end
end
