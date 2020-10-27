defmodule MnogobotDiscord.Consumer do
  @moduledoc """
    Consumes events and reacts to them
  """

  use Nostrum.Consumer
  alias Nostrum.Struct.{
    Message,
    User,
  }
  alias MnogobotDiscord, as: Platform
  alias Mnogobot.Api
  require Logger

  @platform "discord"

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %Message{content: content, author: %User{id: user_id}, channel_id: channel_id} = msg, _ws_state}) do
    Logger.debug("Message create")
    unless msg.author.bot do
      case Api.update_state(user_id, channel_id, @platform, content, Platform.dialogs()) do
        :ignore ->
          Logger.debug("Ignore state update")
          :ignore
        state ->
          Logger.debug("Updating state")
          Api.trigger_dialog(state, msg, Platform.actions_mappings())
      end
    end
  end

  def handle_event(_other) do
  end

end
