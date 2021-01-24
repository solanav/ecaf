defmodule Ecaf.Repo do
  use Ecto.Repo,
    otp_app: :ecaf,
    adapter: Ecto.Adapters.Postgres
end
