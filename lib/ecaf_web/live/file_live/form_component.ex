defmodule EcafWeb.FileLive.FormComponent do
  use EcafWeb, :live_component

  alias Ecaf.Files

  @impl true
  def update(%{file: file} = assigns, socket) do
    changeset = Files.change_file(file)

    {:ok, socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:avatar, accept: :any, max_entries: 16, max_file_size: 2_000_000_000, auto_upload: true)
    }
  end

  @impl true
  def handle_event("validate", %{"file" => file_params}, socket) do
    degree = if file_params["degree"] != nil do
      file_params["degree"]
      |> String.split(" - ")
      |> Enum.at(0)
      |> String.split("/")
      |> Enum.at(1)
    else
      nil
    end

    faculty = if file_params["faculty"] != nil do
      file_params["degree"]
      |> String.split(" - ")
      |> Enum.at(0)
    else
      nil
    end

    faculty = file_params["faculty"]
    |> String.split(" - ")
    |> Enum.at(0)

    changeset = socket.assigns.file
    |> Files.change_file(file_params)
    |> Map.put(:action, :validate)

    {:noreply, socket
      |> assign(:changeset, changeset)
      |> assign(:faculty, faculty)
      |> assign(:degree, degree)
      |> assign(:password, file_params["beta_password"])
    }
  end

  def handle_event("save", %{"file" => file_params}, socket) do
    password = file_params["beta_password"]

    # If password, approve the upload automatically
    approved = password == "lWVbe3dBcHW9eAci9Vzy"
    file_params = Map.put(file_params, "approved", approved)

    # Temporal default parameters
    file_params = Map.put(file_params, "year", 1)
    file_params = Map.put(file_params, "university", "Universidad Autonoma de Madrid")

    save_file(socket, socket.assigns.action, file_params)
  end

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

  defp save_file(socket, :edit, file_params) do
    case Files.update_file(socket.assigns.file, file_params) do
      {:ok, _file} ->
        {:noreply,
         socket
         |> put_flash(:info, "File updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_file(socket, :new, file_params) do
    # For each entry of files
    case uploaded_entries(socket, :avatar) do
      {[_|_] = entries, []} ->
        Enum.map(entries, fn entry ->
          # Save original file name
          file_name = entry.client_name
          file_params = Map.put(file_params, "name", file_name)

          # Complete name
          {:cont, name, i} = Stream.unfold({:cont, file_name, 0}, fn
            {:cont, n, 0} ->
              dest = Path.join("priv/static/uploads", n)
              if File.exists?(dest) do
                {{:cont, n, 0}, {:cont, n, 1}}
              else
                {{:cont, n, 0}, {:halt, n, 0}}
              end
            {:cont, n, i} ->
              dest = Path.join("priv/static/uploads", "#{i}_#{n}")
              if File.exists?(dest) do
                {{:cont, n, i}, {:cont, n, i + 1}}
              else
                {{:cont, n, i}, {:halt, n, i}}
              end
            {:halt, _n, _i} -> nil
          end) |> Enum.to_list() |> Enum.at(-1)
          name = if i == 0 do
            name
          else
            "#{i}_#{name}"
          end

          # Get the backend name
          file_params = Map.put(file_params, "backname", name)

          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            # Check the hash
            hash = hash_file(path)
            file_params = Map.put(file_params, "hash", hash)

            # Get the ipfs hash
            ipfs_hash = Ecaf.IPFS.add(path)
            file_params = Map.put(file_params, "ipfs_hash", ipfs_hash)

            # Try to save in DB
            {:ok, _file} = Files.create_file(file_params)

            # Move it to the corresponding folder
            dest = Path.join("priv/static/uploads", name)
            File.cp!(path, dest)
            Routes.static_path(socket, "/uploads/#{name}")
          end)
        end)

      _ -> {:noreply, socket}
    end

    {:noreply, push_redirect(socket, to: socket.assigns.return_to)}
  end
end
