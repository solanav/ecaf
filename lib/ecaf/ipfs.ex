defmodule Ecaf.IPFS do
  @baseurl "http://127.0.0.1:5001/api/v0"

  def add(path) do
    %{"Hash" => hash} = HTTPoison.post(
      @baseurl <> "/add",
      {:multipart, [{:file, path}]},
      [],
      recv_timeout: 30000
    )
    |> parse

    hash
  end

  defp parse({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    case Jason.decode(body) do
      {:ok, data} -> data
      {:error, _} ->
        {:ok, [{hash, data}]} = :erl_tar.extract({:binary, body}, [:memory])
        data
      end
  end

  defp parse({:error, e}) do
    IO.inspect("Failed to add file to IPFS: " <> inspect(e))

    %{"Hash" => "None"}
  end
end
