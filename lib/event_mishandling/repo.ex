defmodule EventMishandling.Repo do
  use Ecto.Repo,
    otp_app: :event_mishandling,
    adapter: Ecto.Adapters.Postgres
end
