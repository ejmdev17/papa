defmodule Papa.VisitsTest do
  use Papa.DataCase

  alias Papa.Visits

  describe "visit" do
    alias Papa.Visits.Visit

    import Papa.VisitsFixtures

    @invalid_attrs %{date: nil, member_id: nil, minutes: nil, pal_id: nil, status: nil}

    test "list_visit/0 returns all visit" do
      visit = visit_fixture()
      assert Visits.list_visit() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Visits.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      valid_attrs = %{date: ~D[2024-04-13], member_id: 42, minutes: 42, pal_id: 42, status: "some status"}

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
      update_attrs = %{date: ~D[2024-04-14], member_id: 43, minutes: 43, pal_id: 43, status: "some updated status"}

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
