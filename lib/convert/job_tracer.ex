defmodule Convert.JobTracer do
  def job_status(job_id) do
    case valid_job_id?(job_id) && Registry.lookup(__MODULE__, job_id) do
      [{job_pid, _}] -> Convert.Job.job_status(job_pid)
      [] -> :not_found
      _ -> :false
    end
  end

  defp valid_job_id?(job_id) do
    Regex.match?(~r/^[[:digit:][:upper:]]{32}+$/u, job_id)
  end
end
