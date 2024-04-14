defmodule Papa.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :is_member, :boolean, default: false, null: false
      add :is_pal, :boolean, default: false, null: false
      add :minutes, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
