defmodule Ecaf.Repo.Migrations.AddIpfs do
  use Ecto.Migration

  def change do
    alter table(:files) do
      # Add a hash so we can avoid repeated files
      add :ipfs_hash, :string
    end
  end
end
