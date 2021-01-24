defmodule Ecaf.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :backname, :string
    field :course, :string
    field :degree, :string
    field :description, :string
    field :name, :string
    field :type, :string
    field :university, :string
    field :uploader, :string
    field :year, :integer
    field :hash, :string
    field :professor, :string
    field :approved, :boolean
    field :ipfs_hash, :string

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:backname, :name, :uploader, :description, :type, :university, :degree, :year, :course, :hash, :professor, :approved, :ipfs_hash])
    |> validate_required([:backname, :name, :type, :university, :degree, :year, :course])
    |> unique_constraint([:backname, :hash])
  end
end
