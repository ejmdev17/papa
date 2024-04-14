defmodule Papa.VisitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Papa.Visits` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(%{
        date: ~D[2024-04-13],
        member_id: 42,
        minutes: 42,
        pal_id: 42,
        status: "some status"
      })
      |> Papa.Visits.create_visit()

    visit
  end
end
