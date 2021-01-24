defmodule Ecaf.FilesTest do
  use Ecaf.DataCase

  alias Ecaf.Files

  describe "files" do
    alias Ecaf.Files.File

    @valid_attrs %{backname: "some backname", course: "some course", degree: "some degree", description: "some description", name: "some name", type: "some type", university: "some university", uploader: "some uploader", year: 42}
    @update_attrs %{backname: "some updated backname", course: "some updated course", degree: "some updated degree", description: "some updated description", name: "some updated name", type: "some updated type", university: "some updated university", uploader: "some updated uploader", year: 43}
    @invalid_attrs %{backname: nil, course: nil, degree: nil, description: nil, name: nil, type: nil, university: nil, uploader: nil, year: nil}

    def file_fixture(attrs \\ %{}) do
      {:ok, file} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Files.create_file()

      file
    end

    test "list_files/0 returns all files" do
      file = file_fixture()
      assert Files.list_files() == [file]
    end

    test "get_file!/1 returns the file with given id" do
      file = file_fixture()
      assert Files.get_file!(file.id) == file
    end

    test "create_file/1 with valid data creates a file" do
      assert {:ok, %File{} = file} = Files.create_file(@valid_attrs)
      assert file.backname == "some backname"
      assert file.course == "some course"
      assert file.degree == "some degree"
      assert file.description == "some description"
      assert file.name == "some name"
      assert file.type == "some type"
      assert file.university == "some university"
      assert file.uploader == "some uploader"
      assert file.year == 42
    end

    test "create_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Files.create_file(@invalid_attrs)
    end

    test "update_file/2 with valid data updates the file" do
      file = file_fixture()
      assert {:ok, %File{} = file} = Files.update_file(file, @update_attrs)
      assert file.backname == "some updated backname"
      assert file.course == "some updated course"
      assert file.degree == "some updated degree"
      assert file.description == "some updated description"
      assert file.name == "some updated name"
      assert file.type == "some updated type"
      assert file.university == "some updated university"
      assert file.uploader == "some updated uploader"
      assert file.year == 43
    end

    test "update_file/2 with invalid data returns error changeset" do
      file = file_fixture()
      assert {:error, %Ecto.Changeset{}} = Files.update_file(file, @invalid_attrs)
      assert file == Files.get_file!(file.id)
    end

    test "delete_file/1 deletes the file" do
      file = file_fixture()
      assert {:ok, %File{}} = Files.delete_file(file)
      assert_raise Ecto.NoResultsError, fn -> Files.get_file!(file.id) end
    end

    test "change_file/1 returns a file changeset" do
      file = file_fixture()
      assert %Ecto.Changeset{} = Files.change_file(file)
    end
  end
end
