defmodule MnogobotTelegram.Actions.Say do

  def execute(text_args, %{chat: %{id: channel_id}}, _state) do
    Nadia.send_message(channel_id, Enum.join(text_args))
  end
end