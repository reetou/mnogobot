# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :mnogobot,
  ecto_repos: [Mnogobot.Repo]

config :mnogobot_discord,
  bot_config_path: "priv/actions_encoded.json",
  dialogs: []

config :mnogobot_telegram,
  bot_config_path: "priv/actions_encoded.json",
  dialogs: []

config :nadia,
  token: System.get_env("TELEGRAM_TOKEN")

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :mnogobot_web,
  ecto_repos: [Mnogobot.Repo],
  generators: [context_app: :mnogobot]

# Configures the endpoint
config :mnogobot_web, MnogobotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TvYPaFyiwreivYXRlPpIfcY3VuthZ5TqI0cp/EjEj37tuAEmomiaC6r94UM6ZMY6",
  render_errors: [view: MnogobotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mnogobot.PubSub,
  live_view: [signing_salt: "UWU87tiP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
