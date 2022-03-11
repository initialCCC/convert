defmodule ConvertWeb.VideoController do
  use ConvertWeb, :controller
  def create(conn, %{"video" => _plug_upload}) do
    json(conn, %{hello: "World"})
  end
end
