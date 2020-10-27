defmodule Mnogobot.Api do
  alias Mnogobot.Dialog.State
  alias Mnogobot.Dialog.Action
  alias Mnogobot.Dialog
  require Logger

  def init_state(user_id, channel_id, platform, text, dialogs) do
    with %Dialog{} = dialog <- Dialog.for_message(text, dialogs) do
      %State{
        current_action_index: 0,
        dialog: dialog,
        user_id: user_id,
        channel_id: channel_id,
        platform: platform,
        vars: []
      }
      |> IO.inspect(label: "Gonna save inited state")
    else
      nil ->
        Logger.error("No dialog found for message #{text}")
        :ignore
    end
  end

  def parse_action_args(action, state) do
    Action.apply_vars(action, state)
  end

  def get_state(user_id, channel_id, platform, text, dialogs) do
    State.get(user_id, channel_id, platform)
  end

  def update_state(user_id, channel_id, platform, text, dialogs) do
    state =
      case State.get(user_id, channel_id, platform) do
        nil -> init_state(user_id, channel_id, platform, text, dialogs)
        %State{} = state ->
          state
          |> IO.inspect(label: "State not inited, got this")
          |> reinit_existing_state(user_id, channel_id, platform, text, dialogs)
          |> IO.inspect(label: "Trigger next state?")
          |> trigger_next_state(text)
      end
    State.write_or_delete_finished(state, user_id, channel_id, platform)
    |> IO.inspect(label: "Updated or deleted finished state?")
    state
  end

  def trigger_next_state({:skip, state}, message_text), do: state
  def trigger_next_state({:next, state}, message_text) do
    State.next(state, message_text)
  end

  def current_action(state) do
    Action.by_index(state.dialog, state.current_action_index)
  end

  def get_action_module(%{action: action}, mappings) do
    Map.get(mappings, action, :ignore)
  end

  def trigger_dialog(state, %{} = msg, mappings) do
    execute_action(msg, state, mappings)
  end

  defp execute_action(msg, state, mappings) do
    args =
      state
      |> current_action()
      |> parse_action_args(state)

    state
    |> current_action()
    |> get_action_module(mappings)
    |> case do
         :ignore -> :ignore
         module -> module.execute(args, msg, state)
       end
  end

  defp reinit_existing_state(old_state, user_id, channel_id, platform, text, dialogs) do
    case reinit_state_if_triggered(user_id, channel_id, platform, text, dialogs) do
      nil ->
        # No dialogs triggered, iterating to the next state stage
        {:next, old_state}
      state ->
        # Created new state
        {:skip, state}
    end
  end

  defp reinit_state_if_triggered(user_id, channel_id, platform, text, dialogs) do
    dialogs
    |> Dialog.triggered_dialog(text)
    |> create_state_for_dialog(user_id, channel_id, platform, text)
  end

  defp create_state_for_dialog(nil, _, _, _, _), do: nil
  defp create_state_for_dialog(dialog, user_id, channel_id, platform, text) do
    %State{
      current_action_index: 0,
      dialog: dialog,
      user_id: user_id,
      channel_id: channel_id,
      platform: platform,
      vars: []
    }
    |> IO.inspect(label: "Created state for some dialog")
  end
end