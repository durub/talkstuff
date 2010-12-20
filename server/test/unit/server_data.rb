class ServerDataTest < Test::Unit::TestCase
  def setup
    @server_data = ServerData.new :connected => 600, :chatting => 550
  end

  def test_accessing_data
    assert_equal 600, @server_data.get(:connected)
    assert_equal 550, @server_data.get(:chatting)
    assert_equal 600, @server_data[:connected]
    assert_equal 550, @server_data[:chatting]

    object = mock("User list")
    @server_data[:user_list] = object
    assert_equal object, @server_data[:user_list]

    @server_data.set(:chatting_list, object)
    assert_equal object, @server_data.get(:chatting_list)
  end
end
