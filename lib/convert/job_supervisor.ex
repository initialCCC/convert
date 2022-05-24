defmodule Convert.JobSupervisor do
  @converted_files_path Application.compile_env!(:convert, :converted_files_path)
  use DynamicSupervisor

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(init_arg) do
    {:ok, _} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_job(uploaded_file_path) do
    {job_id, processed_path} = generate_job_id()

    job_spec = %{
      id: job_id,
      type: :worker,
      start: {Convert.Job, :start_link, [job_id, processed_path, uploaded_file_path]},
      restart: :permanent
    }

    {:ok, job_pid} = DynamicSupervisor.start_child(__MODULE__, job_spec)
    {job_pid, job_id}
  end

  defp generate_job_id do
    job_id = Base.encode16(:crypto.strong_rand_bytes(16))
    maybe_uniq_file = Path.join(@converted_files_path, job_id)

    case File.write(maybe_uniq_file, "", [:binary, :exclusive, :write]) do
      :ok ->
        {job_id, maybe_uniq_file}

      {:error, :eexist} ->
        generate_job_id()

      {:error, posix_err} ->
        raise("error while creating file #{inspect(posix_err)}")
    end
  end

  def active_children do
    DynamicSupervisor.count_children(__MODULE__).active
  end
end
