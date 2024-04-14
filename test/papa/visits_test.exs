defmodule Papa.VisitsTest do
  use Papa.DataCase

  alias Papa.Visits
  alias Papa.Accounts
  alias Papa.Visits.Visit
  import Papa.VisitsFixtures
  import Papa.AccountsFixtures

  describe "get_visit" do
    test "get_visit/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Visits.get_visit(visit.id) == {:ok, visit}
    end

    test "get_visit/1 returns error when not found" do
      assert Visits.get_visit(999_999_999_999) == {:error, :not_found}
    end
  end

  describe "request_visit" do
    test "successfully requests a visit" do
      member = user_fixture(is_member: true, minutes: 60)
      date = Date.add(Date.utc_today(), 1)
      minutes = 60
      {:ok, visit} = Visits.request_visit(member.id, date, minutes)

      assert visit.member_id == member.id
      assert visit.date == date
      assert visit.minutes == minutes
      assert visit.status == "pending"

      {:ok, member} = Accounts.get_member(member.id)
      assert member.minutes == 0
    end

    test "request fails for non-member" do
      member = user_fixture(is_member: false, minutes: 60)
      date = Date.add(Date.utc_today(), 1)
      assert Visits.request_visit(member.id, date, 60) == {:error, :member_not_found}
    end

    test "request fails for not enough minutes" do
      member = user_fixture(is_member: true, minutes: 60)
      date = Date.add(Date.utc_today(), 1)
      assert Visits.request_visit(member.id, date, 120) == {:error, :member_not_enough_minutes}
    end

    test "request fails for date not in the future" do
      member = user_fixture(is_member: true, minutes: 60)
      date = Date.utc_today()
      assert Visits.request_visit(member.id, date, 60) == {:error, :must_be_a_future_date}
    end
  end

  describe "cancel_visit" do
    test "successfully cancels a visit" do
      member = user_fixture(is_member: true)
      visit = visit_fixture(member_id: member.id, status: "pending")
      {:ok, visit} = Visits.cancel_visit(visit.id)
      assert visit.status == "cancelled"
    end

    test "fails when status is not pending" do
      visit = visit_fixture()
      assert Visits.cancel_visit(visit.id) == {:error, :visit_not_pending}
    end

    test "fails when status is not found" do
      assert Visits.cancel_visit(999_999_999_999) == {:error, :visit_not_found}
    end
  end

  describe "fulfill_visit" do
    setup do
      member = user_fixture(is_member: true, minutes: 100)
      pal = user_fixture(is_pal: true, minutes: 0)
      visit = visit_fixture(member_id: member.id, status: "pending", minutes: 100)

      {:ok, [member: member, pal: pal, visit: visit]}
    end

    test "successful visit fulfillment", %{pal: pal, visit: visit} do
      {:ok, visit} = Visits.fulfill_visit(pal.id, visit.id)
      assert visit.status == "completed"
      assert visit.pal_id == pal.id

      {:ok, pal} = Accounts.get_pal(pal.id)
      assert pal.minutes == 85
    end

    test "fails when visit is not pending", %{member: member, pal: pal} do
      visit = visit_fixture(member_id: member.id, status: "cancelled", minutes: 100)
      assert Visits.fulfill_visit(pal.id, visit.id) == {:error, :visit_not_pending}
    end

    test "fails when pal is the same person as member", %{pal: pal} do
      visit = visit_fixture(member_id: pal.id, status: "cancelled", minutes: 100)
      assert Visits.fulfill_visit(pal.id, visit.id) == {:error, :visit_not_pending}
    end
  end

  describe "visit" do
    alias Papa.Visits.Visit

    import Papa.VisitsFixtures

    @invalid_attrs %{date: nil, member_id: nil, minutes: -1, pal_id: nil, status: nil}

    test "list_visit/0 returns all visit" do
      visit = visit_fixture()
      assert Visits.list_visit() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Visits.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      valid_attrs = %{
        date: ~D[2024-04-13],
        member_id: 42,
        minutes: 42,
        pal_id: 42,
        status: "some status"
      }

      assert {:ok, %Visit{} = visit} = Visits.create_visit(valid_attrs)
      assert visit.date == ~D[2024-04-13]
      assert visit.member_id == 42
      assert visit.minutes == 42
      assert visit.pal_id == 42
      assert visit.status == "some status"
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Visits.create_visit(@invalid_attrs)
    end

    test "update_visit/2 with valid data updates the visit" do
      visit = visit_fixture()

      update_attrs = %{
        date: ~D[2024-04-14],
        member_id: 43,
        minutes: 43,
        pal_id: 43,
        status: "some updated status"
      }

      assert {:ok, %Visit{} = visit} = Visits.update_visit(visit, update_attrs)
      assert visit.date == ~D[2024-04-14]
      assert visit.member_id == 43
      assert visit.minutes == 43
      assert visit.pal_id == 43
      assert visit.status == "some updated status"
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visit = visit_fixture()
      assert {:error, %Ecto.Changeset{}} = Visits.update_visit(visit, @invalid_attrs)
      assert visit == Visits.get_visit!(visit.id)
    end

    test "delete_visit/1 deletes the visit" do
      visit = visit_fixture()
      assert {:ok, %Visit{}} = Visits.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> Visits.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset" do
      visit = visit_fixture()
      assert %Ecto.Changeset{} = Visits.change_visit(visit)
    end
  end
end
