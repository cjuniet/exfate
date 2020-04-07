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
config :exfate,
  ecto_repos: [Exfate.Repo]

config :exfate_web,
  ecto_repos: [Exfate.Repo],
  generators: [context_app: :exfate]

# Configures the endpoint
config :exfate_web, ExfateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6KZrszCywrm47NGhPuN7frC0FrmRqd9xYV3I0dG2YRWHJCn/1/xS/P/GGhX/8sdW",
  render_errors: [view: ExfateWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExfateWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "3RoD3i/r"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
