defmodule Ecaf.Repo.Migrations.AddApproval do
  use Ecto.Migration

  def change do
    alter table(:files) do
      # Add a field to check if the file has been approved
      add :approved, :boolean, default: false
    end
  end
end
