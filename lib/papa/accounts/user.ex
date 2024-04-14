defmodule Papa.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :email, :string
    field :first_name, :string
    field :is_member, :boolean, default: false
    field :is_pal, :boolean, default: false
    field :last_name, :string
    field :minutes, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :is_member, :is_pal, :minutes])
    |> validate_required([:first_name, :last_name, :email, :is_member, :is_pal, :minutes])
  end
end
