defmodule Stackoverflow.Repo do
  use Ecto.Repo,
    otp_app: :stackoverflow,
    adapter: Ecto.Adapters.Postgres
end
