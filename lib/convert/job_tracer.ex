defmodule Convert.JobTracer do

  @spec job_status(String.t()) :: {:path_to_file, Path.t()} | :pending | :not_found
  def job_status(job_id) do
    from_registry(job_id) || Convert.Store.from_store(job_id) || :not_found
  end

  def from_registry(job_id) do
    case Registry.lookup(__MODULE__, job_id) do
      [] -> nil
      _ -> :pending
    end
  end
end
