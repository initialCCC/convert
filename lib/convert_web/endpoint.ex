defmodule ConvertWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :convert

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [VideoReader], pass: ["video/webm"], length: 1  # 20_000_000
  plug ConvertWeb.Router
end
