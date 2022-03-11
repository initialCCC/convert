defmodule Convert.Job do
  use GenServer
  # @ffmpeg System.find_executable("ffmpeg")
  # @converted_files_path Path.expand("./converted_files/")

  def init(_job_id) do
    IO.puts "starting job"
    {:ok, []}
  end

  def start_link(job_id) do
    name = {:via, Registry, {Convert.JobTracer, job_id}}
    GenServer.start_link(__MODULE__, job_id, name: name)
  end
end
