defmodule EcafWeb.FileLive.Index do
  use EcafWeb, :live_view

  alias Ecaf.Files

  @default_faculty "101"
  @default_degree "348"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:search_terms, %{
        name: "",
        description: "",
        uploader: "",
        type: "",
        university: "",
        degree: "",
        year: "",
        course: ""
      })
      |> assign(:faculty, @default_faculty)
      |> assign(:degree, @default_degree)
      |> assign(:last_search, "")
      |> assign(:num_files, list_files(:infinity) |> Enum.count())
      |> assign(:files, list_files())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit File")
    |> assign(:file, Files.get_file!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New File")
    |> assign(:file, %Files.File{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Search")
    |> assign(:file, nil)
  end

  @impl true
  def handle_event("search", %{"search_terms" => search_terms}, socket) do
    # Extract the faculty
    faculty = if search_terms["faculty"] != "All" do
      search_terms["faculty"]
      |> String.split(" - ")
      |> Enum.at(0)
    else
      @default_faculty
    end

    # Extract the degree
    degree = if search_terms["degree"] != "All" do
      search_terms["degree"]
      |> String.split(" - ")
      |> Enum.at(0)
    else
      @default_degree
    end

    # Remove empty terms
    clean_search_terms = search_terms
    |> Enum.filter(fn
      {_k, v} -> v != "" and v != "All"
    end)

    # Search
    files = list_files(:infinity)
    |> Enum.filter(fn f ->
      {res, _} = Enum.reduce(clean_search_terms, {true, :nc}, fn
        {"course",     v}, {res,   _} -> {res and String.contains?(String.downcase(    f.course), String.downcase(v)),  :c}
        {"name",       v}, {res,   c} -> {res and String.contains?(String.downcase(      f.name), String.downcase(v)),   c}
        {"type",       v}, {res,   c} -> {res and String.contains?(String.downcase(      f.type), String.downcase(v)),   c}
        {"university", v}, {res,   c} -> {res and String.contains?(String.downcase(f.university), String.downcase(v)),   c}
        {"year",       v}, {res,   c} -> {res and String.contains?(String.downcase(      f.year), String.downcase(v)),   c}
        {"degree",     v}, {res, :nc} -> {res and String.contains?(String.downcase(    f.degree), String.downcase(v)), :nc}
        _, acc -> acc
      end)

      res
    end)

    {:noreply, socket
      |> assign(:files, files |> Enum.take(100))
      |> assign(:num_files, files |> Enum.count())
      |> assign(:search_terms, search_terms)
      |> assign(:last_search, search_terms["name"])
      |> assign(:faculty, faculty)
      |> assign(:degree, degree)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    file = Files.get_file!(id)
    backname = file.backname
    {:ok, _} = Files.delete_file(file)

    File.rm(Path.join("priv/static/uploads", backname))

    {:noreply, assign(socket, :files, list_files())}
  end

  defp list_files(limit \\ 20) do
    Files.list_files(limit)
  end
end
