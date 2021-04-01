defmodule Ecaf.Repo.Migrations.AddFaculty do
  use Ecto.Migration

  def change do
    alter table(:files) do
      # Add a hash so we can avoid repeated files
      add :faculty, :string
    end
  end
end
