defmodule Ecaf.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :backname, :string
      add :name, :string
      add :uploader, :string
      add :description, :string
      add :type, :string
      add :university, :string
      add :degree, :string
      add :year, :integer
      add :course, :string

      timestamps()
    end

    create unique_index(:files, [:backname])
  end
end
