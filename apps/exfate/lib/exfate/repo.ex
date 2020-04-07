defmodule Exfate.Repo do
  use Ecto.Repo,
    otp_app: :exfate,
    adapter: Ecto.Adapters.Postgres
end
