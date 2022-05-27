defmodule Convert.Store do
  use GenServer
  @table :store
  require Logger

  @impl true
  def init(_opts) do
    # An ETS table holding job id's poiting to processed files
    :ets.new(@table, [:named_table, :set, :public, write_concurrency: true])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:track_process, job_id}, {pid, _}, state) do
    ref = Process.monitor(pid)
    {:reply, :ok, Map.put_new(state, ref, job_id)}
  end

  @impl true
  def handle_info({:DOWN, ref, _, _pid, :normal}, state) do
    %{^ref => job_id} = state

    [{_, processed_path}] = :ets.lookup(@table, job_id)

    :ets.delete(@table, job_id)

    File.rm!(processed_path)

    {:noreply, Map.delete(state, ref)}
  end

  @impl true
  def handle_info({_, _ref, _, _, _reason}, state) do
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
        # the controller's process
        :ok = track_process(job_id)
        {:path_to_file, processed_path}

      _ ->
        nil
    end
  end

  def track_process(job_id) do
    GenServer.call(__MODULE__, {:track_process, job_id})
  end
end
