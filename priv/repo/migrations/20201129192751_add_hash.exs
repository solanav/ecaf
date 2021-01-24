defmodule Ecaf.Repo.Migrations.AddHash do
  use Ecto.Migration

  def change do
    alter table(:files) do
      # Add a hash so we can avoid repeated files
      add :hash, :string

      # Add a professor
      add :professor, :string
    end
  end
end
