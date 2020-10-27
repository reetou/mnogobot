defmodule MnogobotDiscord.Actions.Image do

  alias Nostrum.Api
  require Logger

  def execute(text_args, %{channel_id: channel_id}, _state) do
    url = Enum.join(text_args)
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Api.create_message!(channel_id, file: %{name: "image.png", body: body})
      _ ->
        Logger.error("Cannot get image by #{url}")
    end
  end
end