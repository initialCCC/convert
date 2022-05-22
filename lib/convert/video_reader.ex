defmodule VideoReader do
  require Logger
  alias Plug.Parsers.MULTIPART

  def init(opts) do
    opts
  end

  def parse(conn, "multipart", subtype, headers, opts) do
    if JobLimiter.system_available? do
      opts = MULTIPART.init(opts)
      MULTIPART.parse(conn, "multipart", subtype, headers, opts)
    else
      {:ok, %{}, conn}
    end
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end
end
