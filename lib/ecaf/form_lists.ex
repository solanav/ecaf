defmodule Ecaf.FormLists do
  @universityjson "nuam.json"

  def universities do
    [
      "Universidad Autonoma de Madrid"
    ]
  end

  def types do
    [
      "Examenes",
      "Ejercicios",
      "Apuntes",
      "Practicas",
      "Videos",
      "Libros",
      "Programas",
      "Otros",
    ]
  end

  @spec simplify(binary, :all | :text) :: binary
  def simplify(degree, mode \\ :all) do
    [degree_key, degree_name] = String.split(degree, " - ")

    degree_name = degree_name
    |> String.replace("Graduado/a en ", "")
    |> String.capitalize()

    case mode do
      :all -> degree_key <> " - " <> degree_name
      :text -> degree_name
    end

  end

  def faculties do
    jsondb = Jason.decode!(File.read!(@universityjson))

    Enum.map(jsondb, fn {_faculty_k, faculty_v} ->
      faculty_v["name"]
    end)
  end

  def degrees(faculty) do
    jsondb = Jason.decode!(File.read!(@universityjson))

    Enum.map(jsondb[faculty]["degrees"], fn {_degree_k, degree_v} ->
      degree_v["name"]
    end)
    |> Enum.map(fn name -> faculty <> "/" <> name end)
  end

  def courses(faculty, degree) do
    jsondb = Jason.decode!(File.read!(@universityjson))

    case jsondb[faculty]["degrees"][degree] do
      nil -> []
      degree_v ->
        Enum.map(degree_v["years"], fn {year, _} ->
          year_v = degree_v["years"]

          {
            String.to_atom(year),
            Enum.map(year_v[year], fn {_, asignaturas} -> asignaturas end)
          }
        end)
        |> Enum.filter(fn
          {_, []} -> false
          _ -> true
        end)
    end
  end
end
