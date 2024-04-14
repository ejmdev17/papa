defmodule Papa.Repo.Migrations.CreateVisit do
  use Ecto.Migration

  def change do
    create table(:visit) do
      add :member_id, :integer
      add :pal_id, :integer
      add :date, :date
      add :minutes, :integer
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
