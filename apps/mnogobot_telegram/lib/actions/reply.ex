defmodule MnogobotTelegram.Actions.Reply do

  def execute(text_args, %{chat: %{id: channel_id}, message_id: message_id}, _state) do
    Nadia.send_message(channel_id, Enum.join(text_args), reply_to_message_id: message_id)
  end
end