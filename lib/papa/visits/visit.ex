defmodule Papa.Visits.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visit" do
    field :date, :date
    field :member_id, :integer
    field :minutes, :integer
    field :pal_id, :integer
    field :status, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:member_id, :pal_id, :date, :minutes, :status])
    |> validate_required([:member_id, :date, :minutes, :status])
    |> validate_number(:minutes, greater_than_or_equal_to: 0)
  end
end
