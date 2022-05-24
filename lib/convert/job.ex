defmodule Convert.Job do
  use GenServer
  @ffmpeg_path Application.compile_env!(:convert, :ffmpeg_path)

  @impl true
  def init(args) do
    {:ok, Convert.Job.State.new(args), {:continue, []}}
  end

  @impl true
  def handle_continue(_, state) do
    port = Port.open(
      {:spawn_executable, @ffmpeg_path},
      [:binary, :nouse_stdio, :exit_status, args: [
        "-hide_banner", "-nostdin", "-y", "-loglevel", "quiet",
        "-f", "webm",
        "-i", state.uploaded_path,
        "-f", "mp4", state.processed_path
        ]
      ]
    )

    {:noreply, %{state | port: port}}
  end

  @impl true
  def handle_call(:status, _, state) do
    %{port: port, processed_path: processed_path} = state

    with nil <- Port.info(port), true <- File.exists?(processed_path) do
      {:stop, :normal, handle_file(processed_path), state}
    else
      false -> {:stop, :normal, :failed, state}

      _ -> {:reply, :pending, state}
    end
  end

  @impl true
  def handle_info({_port, {:exit_status, _exit_status}}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect(message, label: "unknown message in job")
    {:noreply, state}
  end

  def start_link(job_id, processed_path, uploaded_file_path) do
    name = {:via, Registry, {Convert.JobTracer, job_id}}
    GenServer.start_link(__MODULE__, {processed_path, uploaded_file_path}, name: name)
  end

  def job_status(job_pid) do
    GenServer.call(job_pid, :status)
  end

  defp handle_file(file_path) do
    bin = File.read!(file_path)
    :ok = File.rm!(file_path)
    {:binary, bin}
  end
end
