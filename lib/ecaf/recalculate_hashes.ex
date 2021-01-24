defmodule RecalculateHashes do
  defp hash_file(file_path) do
    hash_ref = :crypto.hash_init(:sha256)

    File.stream!(file_path, [], 2_048)
    |> Enum.reduce(hash_ref, fn chunk, prev_ref->
      new_ref = :crypto.hash_update(prev_ref, chunk)
      new_ref
    end)
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end


end
