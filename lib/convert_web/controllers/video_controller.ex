defmodule ConvertWeb.VideoController do
  use ConvertWeb, :controller

  def create(conn, %{"video" => video}) do
    {job_pid, job_id} = Convert.JobSupervisor.start_job(video.path)

    :ok = Plug.Upload.give_away(video, job_pid)
    json(conn, %{job_id: job_id})
  end

  def show(conn, %{"job_id" => job_id}) do
    case Convert.JobTracer.job_status(job_id) do
      {:completed, processed_path} -> send_file(conn, 200, processed_path)

      status -> json(conn, %{"job_status" => format_status(status)})
    end
  end

  defp format_status(:false), do: "invalid job id"
  defp format_status(:failed), do: "failed converting file"
  defp format_status(:pending), do: "file still converting"
  defp format_status(:not_found), do: "file not found in the system"
end
