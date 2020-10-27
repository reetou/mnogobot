defmodule MnogobotTelegram.Actions.Image do

  def execute(text_args, %{chat: %{id: channel_id}}, _state) do
    Nadia.send_photo(channel_id, Enum.join(text_args))
  end
end