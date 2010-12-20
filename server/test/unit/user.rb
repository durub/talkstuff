class UserTest < Test::Unit::TestCase
  def setup
    @user = User.new(:useless => "info", :six => 6)
  end

  def test_initialization
    assert_equal "info", @user.get(:useless)
    assert_equal 6, @user.get(:six)
  end

  def test_session
    @user.set(:custom_key, "string")
    assert_equal "string", @user.get(:custom_key)

    @user[:custom_key] = "string2"
    assert_equal "string2", @user[:custom_key]

    @user.unset(:custom_key)
    assert_equal nil, @user.get(:custom_key)
  end

  def test_socket
    socket = mock("Custom Socket") do
      stubs(:state).returns(1).then.returns(3) # OPEN = 1, CLOSED = 3
    end

    @user.socket = socket
    assert_equal socket, @user.socket
    assert @user.connected?

    @user.socket = socket
    assert_equal socket, @user.socket
    assert !@user.connected?
  end

  def test_admin
    assert User.new(:admin => true).admin?
    assert User.new(:admin => 1).admin?
    assert User.new(:admin => "yes").admin?

    assert !@user.admin?
    assert !User.new.admin?
    assert !User.new(:admin => nil).admin?
    assert !User.new(:admin => false).admin?
  end
end
