defmodule ConvertWeb.VideoController do
  require Logger
  use ConvertWeb, :controller

  def create(conn, %{"video" => %{path: path}}) do
    {job_pid, job_id} = Convert.JobSupervisor.start_job(path)

    :ok = Plug.Upload.give_away(path, job_pid)
    json(conn, %{job_id: job_id})
  end

  def create(conn, _) do
    json(conn, %{"status" => format_status(:system_overload)})
  end

  def show(conn, %{"job_id" => job_id}) do
    case Convert.JobTracer.job_status(job_id) do
      {:path_to_file, processed_path} ->
        conn
        |> put_resp_content_type("video/mp4", nil)
        |> send_file(200, processed_path)

      status ->
        json(conn, %{"status" => format_status(status)})
    end
  end

  defp format_status(:pending), do: "file still converting"
  defp format_status(:not_found), do: "file not found in the system"
  defp format_status(:system_overload), do: "the system is at maximum capacity"
end
