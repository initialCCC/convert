defmodule Convert.Job.State do
  defstruct [:port, :processed_path, :uploaded_path]
  @converted_files_path Application.compile_env!(:convert, :converted_files_path)

  def new({job_id, uploaded_file_path}) do
    %__MODULE__{
      processed_path: Path.join(@converted_files_path, [job_id, ".mp4"]),
      uploaded_path: uploaded_file_path
    }
  end
end
