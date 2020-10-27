defmodule Mnogobot.Repo do
  use Ecto.Repo,
    otp_app: :mnogobot,
    adapter: Ecto.Adapters.Postgres
end
