defmodule MnogobotTelegram.Matcher do
  use GenServer
  alias Mnogobot.Api
  alias MnogobotTelegram, as: Platform
  require Logger

  @platform "telegram"

  # Server

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(%{message: message}, state) do
    Logger.debug("Update received #{message.from.id} #{message.chat.id}")
    Platform.dialogs()
    case Api.update_state(message.from.id, message.chat.id, @platform, message.text, Platform.dialogs()) do
      :ignore ->
        Logger.debug("Telegram: Ignore state update")
        :ignore
      state ->
        Logger.debug("Telegram: Updating state")
        Api.trigger_dialog(state, message, Platform.actions_mappings())
    end
    {:noreply, state}
  end

  # Client

  def match(message) do
    GenServer.cast(__MODULE__, message)
  end
end