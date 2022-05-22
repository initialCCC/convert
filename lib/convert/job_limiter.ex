defmodule JobLimiter do
  use GenServer
  alias Convert.JobSupervisor
  @max_jobs Application.compile_env!(:convert, :capacity)

  defmodule State do
    defstruct uploads: %{}
  end

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)
    {:ok, %State{}}
  end

  @impl true
  def handle_call(:system_available?, {from_pid, _ref}, %{uploads: uploads} = state) do
    # * Videos that are getting uploaded are part of the workload
    current_workload = Kernel.map_size(uploads) + JobSupervisor.active_children

    if current_workload < @max_jobs do
      mref = Process.monitor(from_pid)
      uploads = Map.put(uploads, from_pid, mref)
      {:reply, true, %{state | uploads: uploads}}
    else
      {:reply, false, state}
    end
  end

  @doc """
  At this point the supervisor has either already started an ffmpeg
  port `reason is :normal` so the children count is higher or the upload
  has failed so the children count stays the same `reason is :shutdown`
  """
  @impl true
  def handle_info({:DOWN, _ref, _, upload_pid, _reason}, %{uploads: uploads} = state) do
    {:noreply, %{state | uploads: Map.delete(uploads, upload_pid)}}
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect(message, label: "unknown message received in limiter")
    {:noreply, state}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def system_available? do
    GenServer.call(__MODULE__, :system_available?)
  end
end
