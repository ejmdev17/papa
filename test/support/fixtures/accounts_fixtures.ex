defmodule Papa.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Papa.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "john.doe@example.org",
        first_name: "some first_name",
        is_member: true,
        is_pal: true,
        last_name: "some last_name",
        minutes: 42
      })
      |> Papa.Accounts.create_user()

    user
  end
end
