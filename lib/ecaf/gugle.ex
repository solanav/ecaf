defmodule Ecaf.Gugle do
  def clean_search_terms(search_terms) do
    search_terms
    |> Enum.filter(fn {_k, v} ->
      v != "" and v != "All"
    end)
    |> Enum.map(fn {k, v} ->
      if k == "type" do
        {k, v |> String.downcase()}
      else
        {k, v}
      end
    end)
  end

  def search(search_terms) do
    # Rid the terms of garbage
    search_terms = clean_search_terms(search_terms)

    # Create the where keyword list
    where = search_terms
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    name = Keyword.fetch(where, :name)
    where = Keyword.delete(where, :name)

    # Filter everything except name
    files = Ecaf.Files.search_files(where)

    # Filter by name
    files = case name do
      {:ok, name} ->
        Enum.map(files, fn f ->
          db_name = String.downcase(f.name)
          param_name = String.downcase(name)

          score = if String.contains?(db_name, param_name) do
            String.jaro_distance(db_name, param_name) + 1
          else
            String.jaro_distance(db_name, param_name)
          end

          {score, f}
        end)
        |> Enum.sort(fn {score1, _f1}, {score2, _f2} -> score1 >= score2 end)
        |> Enum.filter(fn {s, _} -> s > 0.5 end)
        |> Enum.map(fn {_, f} -> f end)
      :error ->
        files
    end

    {files, files |> Enum.count()}
  end
end
