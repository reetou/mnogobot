defmodule MnogobotDiscord.Consumer do
  @moduledoc """
    Consumes events and reacts to them
  """

  use Nostrum.Consumer
  alias Nostrum.Struct.{
    Message,
    User,
  }
  alias Nostrum.Cache.Me
  alias MnogobotDiscord, as: Platform
  alias Mnogobot.Api
  import Nostrum.Api

  @platform "discord"

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, %{content: content, author: %{id: user_id}, channel_id: channel_id} = msg, _ws_state}) do
    case Api.get_state(user_id, channel_id, @platform) do
      nil -> Platform.init_dialogs(msg, [])
      %State{} = state -> Platform.continue_dialog(state, msg)
    end
  end

  def handle_event(_other) do
  end

end
