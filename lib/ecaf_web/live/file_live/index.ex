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
      |> assign(:faculty_enabled, false)
      |> assign(:degree_enabled, false)
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
    {faculty, faculty_enabled} = case Map.fetch(search_terms, "faculty") do
      {:ok, "All"} ->
        {@default_faculty, false}
      {:ok, faculty} ->
        {faculty |> String.split(" - ") |> Enum.at(0), true}
      :error ->
        {@default_faculty, false}
    end

    # Extract the degree
    {degree, degree_enabled} = case Map.fetch(search_terms, "degree") do
      {:ok, "All"} ->
        {@default_degree, false}
      {:ok, degree} ->
        {degree |> String.split(" - ") |> Enum.at(0), true}
      :error ->
        {@default_degree, false}
    end

    # If faculty is disabled, disable degree too
    degree_enabled = if faculty_enabled do
      degree_enabled
    else
      false
    end

    # Remove empty terms
    clean_search_terms = search_terms
    |> Enum.filter(fn
      {_k, v} -> v != "" and v != "All"
    end)

    # Search
    {files, num_files} = Ecaf.Gugle.search(search_terms)

    {:noreply, socket
      |> assign(:faculty_enabled, faculty_enabled)
      |> assign(:degree_enabled, degree_enabled)
      |> assign(:files, files |> Enum.take(100))
      |> assign(:num_files, num_files)
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
