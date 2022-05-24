defmodule Convert.Job.State do
  defstruct [:port, :processed_path, :uploaded_path]


  def new({processed_path, uploaded_file_path}) do
    %__MODULE__{
      processed_path: processed_path,
      uploaded_path: uploaded_file_path
    }
  end
end
