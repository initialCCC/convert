defmodule Convert.JobSupervisor do
  use DynamicSupervisor

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(init_arg) do
    IO.puts "starting jobs supervisor"
    {:ok, _} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_job(uploaded_file_path) do
    job_id = generate_job_id()

    job_spec = %{
      id: job_id,
      type: :worker,
      start: {Convert.Job, :start_link, [job_id, uploaded_file_path]},
      restart: :transient
    }

    {:ok, job_pid} = DynamicSupervisor.start_child(__MODULE__, job_spec)
    {job_pid, job_id}
  end

  defp generate_job_id do
    Base.encode16(:crypto.strong_rand_bytes(16))
  end
end
