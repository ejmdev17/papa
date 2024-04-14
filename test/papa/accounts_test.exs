defmodule Papa.AccountsTest do
  use Papa.DataCase

  alias Papa.Accounts

  describe "user" do
    alias Papa.Accounts.User

    import Papa.AccountsFixtures

    @invalid_attrs %{email: nil, first_name: nil, is_member: nil, is_pal: nil, last_name: nil, minutes: nil}

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert Accounts.list_user() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", first_name: "some first_name", is_member: true, is_pal: true, last_name: "some last_name", minutes: 42}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.is_member == true
      assert user.is_pal == true
      assert user.last_name == "some last_name"
      assert user.minutes == 42
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", first_name: "some updated first_name", is_member: false, is_pal: false, last_name: "some updated last_name", minutes: 43}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.is_member == false
      assert user.is_pal == false
      assert user.last_name == "some updated last_name"
      assert user.minutes == 43
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
