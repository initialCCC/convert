# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :convert,
  capacity: 3, # maximum number of ffmpeg processes that can run at a time
  max_upload_size: 10, # maximum file size in mega bytes
  ffmpeg_path: System.find_executable("ffmpeg"),
  converted_files_path: Path.expand("./converted_files/")

# Configures the endpoint
config :convert, ConvertWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ConvertWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Convert.PubSub,
  live_view: [signing_salt: "cF8JDbxr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
