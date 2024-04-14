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
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/)
    |> validate_number(:minutes, greater_than_or_equal_to: 0)
  end
end
