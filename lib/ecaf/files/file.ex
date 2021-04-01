defmodule Ecaf.Files.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    # University related info
    field :university, :string
    field :faculty, :string
    field :degree, :string
    field :year, :integer
    field :course, :string

    # Properties
    field :backname, :string
    field :name, :string
    field :description, :string
    field :uploader, :string

    # Extra info
    field :type, :string
    field :professor, :string

    # Meta
    field :hash, :string
    field :ipfs_hash, :string
    field :approved, :boolean

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:backname, :name, :uploader, :description, :type, :university, :degree, :year, :course, :hash, :professor, :approved, :ipfs_hash, :faculty])
    |> validate_required([:backname, :name, :type, :university, :degree, :year, :course, :faculty])
    |> unique_constraint([:backname, :hash])
  end
end
