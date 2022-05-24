defmodule Convert.Job do
  use GenServer
  @ffmpeg_path Application.compile_env!(:convert, :ffmpeg_path) || raise("FFMPEG not found !")

  @impl true
  def init(args) do
    {:ok, Convert.Job.State.new(args), {:continue, []}}
  end

  @impl true
  def handle_continue(_, state) do
    port =
      Port.open(
        {:spawn_executable, @ffmpeg_path},
        [
          :binary,
          :nouse_stdio,
          :exit_status,
          args: [
            "-hide_banner",
            "-nostdin",
            "-y",
            "-loglevel",
            "quiet",
            "-f",
            "webm",
            "-i",
            state.uploaded_path,
            "-f",
            "mp4",
            state.processed_path
          ]
        ]
      )

    {:noreply, %{state | port: port}}
  end

  @impl true
  def handle_info({_port, {:exit_status, 0}}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({_port, {:exit_status, exit_status}}, state) do
    {:stop, {:shutdown, exit_status}, state}
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect(message, label: "unknown message in job")
    {:noreply, state}
  end

  @impl true
  def terminate(:normal, %{processed_path: processed_path}) do
    job_id = Path.basename(processed_path)
    :ets.insert(:store, {job_id, processed_path})
  end

  def terminate({_shutdown, _exit_status}, _) do
    ### SOME LOGGING
    :ok
  end

  def start_link(job_id, processed_path, uploaded_file_path) do
    name = {:via, Registry, {Convert.JobTracer, job_id}}
    GenServer.start_link(__MODULE__, {processed_path, uploaded_file_path}, name: name)
  end
end
