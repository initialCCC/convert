defmodule Convert.Application do
  @converted_files_path Application.compile_env!(:convert, :converted_files_path)
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ConvertWeb.Telemetry,

      {Phoenix.PubSub, name: Convert.PubSub},

      {JobLimiter, []},

      ConvertWeb.Endpoint,

      Convert.JobSupervisor,

      {Registry, keys: :unique, name: Convert.JobTracer}
    ]

    :ok = create_folder()

    opts = [strategy: :one_for_one, name: Convert.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp create_folder do
    unless File.exists?(@converted_files_path) do
      File.mkdir!(@converted_files_path)
    else
      :ok
    end
  end
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ConvertWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
