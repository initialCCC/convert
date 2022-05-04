defmodule Convert.JobTracer do

  @spec job_status(job_id :: binary()) :: :not_found | :failed | :pending | {:binary, binary()}
  def job_status(job_id) do
    case Registry.lookup(__MODULE__, job_id) do
      [{job_pid, _}] -> Convert.Job.job_status(job_pid)
      [] -> :not_found
    end
  end
end
