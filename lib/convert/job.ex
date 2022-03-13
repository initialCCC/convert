defmodule Convert.Job do
  defmodule State do
    defstruct [:port, :processed_path, :uploaded_path]
  end

  use GenServer
  @ffmpeg_path System.find_executable("ffmpeg")
  @converted_files_path Path.expand("./converted_files/")

  def init({job_id, uploaded_file_path}) do
    state = %Convert.Job.State{
      processed_path: Path.join(@converted_files_path, [job_id, ".mp4"]),
      uploaded_path: uploaded_file_path
    }
    {:ok, state, {:continue, []}}
  end

  def handle_continue(_, state) do
    port = Port.open(
      {:spawn_executable, @ffmpeg_path},
      [:binary, args: [
        "-loglevel",
        "quiet",
        "-nostdin",
        "-i",
        state.uploaded_path,
        state.processed_path
        ]
      ]
    )

    {:noreply, %{state | port: port}}
  end

  def handle_call(:status, _, state) do
    %{port: port, processed_path: processed_path} = state

    with nil <- Port.info(port), true <- File.exists?(processed_path) do
      {:stop, :normal, {:completed, processed_path}, state}
    else
      false -> {:stop, :normal, :failed, state}

      _ -> {:reply, :pending, state}
    end
  end

  def start_link(job_id, uploaded_file_path) do
    name = {:via, Registry, {Convert.JobTracer, job_id}}

    GenServer.start_link(__MODULE__, {job_id, uploaded_file_path}, name: name)
  end

  def job_status(job_pid) do
    GenServer.call(job_pid, :status)
  end
end
