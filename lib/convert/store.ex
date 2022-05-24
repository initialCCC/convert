defmodule Convert.Store do
  use GenServer
  @table :store

  @impl true
  def init(_opts) do
    # An ETS table holding job id's poiting to processed files
    :ets.new(@table, [:named_table, :set, :public, write_concurrency: true])
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:track_process, pid, job_id}, state) do
    ref = Process.monitor(pid)
    {:noreply, Map.put_new(state, ref, job_id)}
  end

  @doc """
  Handle down messages from controllers. (might be problematic if many client query it)
  """
  @impl true
  def handle_info({:DOWN, ref, _, pid, :normal}, state) do
    IO.puts "Received down signal ref : #{inspect ref} from pid #{inspect pid}"
    IO.puts "Sleeping before deleting"
    Process.sleep(2000)
    %{^ref => job_id} = state

    [{_, processed_path}] = :ets.lookup(@table, job_id)

    :ets.delete(@table, job_id)

    File.rm!(processed_path)

    {:noreply, Map.delete(state, ref)}
  end

  @impl true
  def handle_info({_, _ref, _, _, reason}, state) do
    IO.inspect(reason, label: "crashed with reason")
    {:noreply, state}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add_to_store(job_id, processed_path) do
    :ets.insert(@table, {job_id, processed_path})
  end

  def from_store(job_id) do
    case :ets.lookup(@table, job_id) do
      [{_job_id, processed_path}] ->
        track_process(job_id) # the controller's process
        {:path_to_file, processed_path}
      _ ->
        nil
    end
  end

  def track_process(job_id) do
    GenServer.cast(__MODULE__, {:track_process, self(), job_id})
  end
end
