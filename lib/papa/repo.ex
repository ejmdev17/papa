defmodule Papa.Repo do
  use Ecto.Repo,
    otp_app: :papa,
    adapter: Ecto.Adapters.SQLite3
end
