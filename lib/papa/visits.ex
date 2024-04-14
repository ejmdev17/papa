defmodule Papa.Visits do
  @moduledoc """
  The Visits context.
  """

  import Ecto.Query, warn: false
  alias Papa.Repo

  alias Papa.Visits.Visit
  alias Papa.Accounts

  @type visit_request_error ::
          :user_is_not_a_member |
          :member_not_enough_minutes |
          :must_be_a_future_date

  @doc """
  Requests a visit from a member.
  """
  @spec request_visit(integer(), Date.t(), integer()) ::
          {:ok, Visit.t()} |
          {:error, visit_request_error() | :not_found | Ecto.Changeset.t()}
  def request_visit(member_id, date, minutes) do
    with {:ok, member} <- Accounts.get_member(member_id),
         {:ok, visit} <- schedule_visit(member, date, minutes) do
      {:ok, visit}
    end
  end

  defp schedule_visit(member, utc_date, minutes) do
    with {:is_member, true} <- {:is_member, member.is_member},
         {:member_has_enough_minutes, true} <-
           {:member_has_enough_minutes, member.minutes >= minutes},
         {:future_date, true} <- {:future_date, utc_date > Date.utc_today()} do
      Repo.transact(fn ->
        Accounts.update_user(member, %{minutes: member.minutes - minutes})

        create_visit(%{
          member_id: member.id,
          pal_id: nil,
          date: utc_date,
          minutes: minutes,
          status: "pending"
        })
      end)
    else
      {:is_member, false} -> {:error, :user_is_not_a_member}
      {:member_has_enough_minutes, false} -> {:error, :member_not_enough_minutes}
      {:future_date, false} -> {:error, :must_be_a_future_date}
      error -> error
    end
  end

  @type visit_cancellation_error ::
          :visit_not_found |
          :visit_not_pending
  @doc """
  Cancels a visit, returns requested minutes to the member.
  """
  @spec cancel_visit(integer()) ::
          {:ok, Visit.t()} |
          {:error, visit_cancellation_error() | Ecto.Changeset.t()}
  def cancel_visit(visit_id) do
    with {:ok, %{status: "pending"} = visit} <- get_visit(visit_id),
         {:ok, member} <- Accounts.get_member(visit.member_id) do
      Repo.transact(fn ->
       {:ok, visit} = update_visit(visit, %{status: "cancelled"})
        Accounts.update_user(member, %{minutes: member.minutes + visit.minutes})
        {:ok, visit}
      end)
    else
      {:error, :not_found} -> {:error, :visit_not_found}
      {:ok, %Visit{}} -> {:error, :visit_not_pending}
      error -> error
    end
  end

  @type visit_fulfillment_error ::
          :user_is_not_a_pal |
          :visit_not_pending |
          :pal_is_member

  @doc """
  Fulfills a visit.  Transfers 85% of the visit minutes to the PAL, 15% is kept by the system.
  """
  @spec fulfill_visit(integer(), integer()) ::
          {:ok, Visit.t()} |
          {:error, visit_fulfillment_error() | Ecto.Changeset.t()}
  def fulfill_visit(pal_id, visit_id) do
    with {:ok, pal} <- Accounts.get_pal(pal_id),
         {:ok, visit} <- get_visit(visit_id) do
      complete_visit(pal, visit)
    end
  end

  defp complete_visit(pal, visit) do
    with {:is_pal, true} <- {:is_pal, pal.is_pal},
         {:visit_pending, true} <- {:visit_pending, visit.status == "pending"},
         {:pal_not_member, true} <- {:pal_not_member, pal.id != visit.member_id} do
      Repo.transact(fn ->
        transferred_minutes = Kernel.trunc(visit.minutes * 0.85)
        {:ok, pal} = Accounts.update_user(pal, %{minutes: pal.minutes + transferred_minutes})
        update_visit(visit, %{pal_id: pal.id, status: "completed"})
      end)
    else
      {:is_pal, false} -> {:error, :user_is_not_a_pal}
      {:visit_pending, false} -> {:error, :visit_not_pending}
      {:pal_not_member, true} -> {:error, :pal_is_member}
      error -> error
    end
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit(123)
      {:ok, %Visit{}}

      iex> get_visit(456)
      {:error, :not_found}

  """
  def get_visit(id) do
    case Repo.get(Visit, id) do
      nil -> {:error, :not_found}
      visit -> {:ok, visit}
    end
  end

  @doc """
  Returns the list of visit.

  ## Examples

      iex> list_visit()
      [%Visit{}, ...]

  """
  def list_visit do
    Repo.all(Visit)
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit!(123)
      %Visit{}

      iex> get_visit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_visit!(id), do: Repo.get!(Visit, id)

  @doc """
  Creates a visit.

  ## Examples

      iex> create_visit(%{field: value})
      {:ok, %Visit{}}

      iex> create_visit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visit(attrs \\ %{}) do
    %Visit{}
    |> Visit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Visit{} = visit, attrs) do
    visit
    |> Visit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a visit.

  ## Examples

      iex> delete_visit(visit)
      {:ok, %Visit{}}

      iex> delete_visit(visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_visit(%Visit{} = visit) do
    Repo.delete(visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking visit changes.

  ## Examples

      iex> change_visit(visit)
      %Ecto.Changeset{data: %Visit{}}

  """
  def change_visit(%Visit{} = visit, attrs \\ %{}) do
    Visit.changeset(visit, attrs)
  end
end
