# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ecaf,
  ecto_repos: [Ecaf.Repo]

# Configures the endpoint
config :ecaf, EcafWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rpuFZPxjn3snABDbIAjGtHz8ZLfrsyxeKKUcL2UVh8MfS0Z27WK3cwylC9oT7NIY",
  render_errors: [view: EcafWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ecaf.PubSub,
  live_view: [signing_salt: "zH665z5O"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
