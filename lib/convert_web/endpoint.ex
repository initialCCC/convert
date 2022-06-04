defmodule ConvertWeb.Endpoint do
  @max_upload_size Application.compile_env(:convert, :max_upload_size) * 1_000_000
  use Phoenix.Endpoint, otp_app: :convert

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [VideoReader], pass: ["video/webm"], length: @max_upload_size
  plug ConvertWeb.Router
end
