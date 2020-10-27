defmodule MnogobotDiscord.Actions.Say do

  alias Nostrum.Api

  def execute(text_args, %{channel_id: channel_id}, _state) do
    Api.create_message!(channel_id, Enum.join(text_args))
  end
end