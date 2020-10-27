defmodule MnogobotDiscord.Actions.Reply do

  alias Nostrum.Api

  def execute(text_args, %{channel_id: channel_id, author: %{id: user_id}}) do
    Api.create_message!(channel_id, "<@#{user_id}>, " <> Enum.join(text_args))
  end
end