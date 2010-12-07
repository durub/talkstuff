class UserListTest < Test::Unit::TestCase
  def setup
    @list = UserList.new
    @user = mock("User")
  end

  def test_adding_and_removing
    @list.add_user(@user)
    assert_equal 1, @list.number_of_users

    @list.remove_user(@user)
    assert_equal 0, @list.number_of_users
  end

  def test_iterators
    @user.stubs(:admin?).returns(false).then.returns(true)

    @list.add_user(@user)

    @list.each_user do |user|
      assert_same @user, user
    end

    @list.each_admin do
      assert false, "The block should not be called, user isn't admin"
    end

    @list.each_admin do |admin|
      assert_same @user, admin
    end
  end
end