class HandlerTest < Test::Unit::TestCase
  def test_handling
    PacketHandler.handle 0x01 do
      "handle it"
    end

    assert_equal "handle it", PacketHandler.call_handler_for(0x01)

    PacketHandler.handle 0x02 do |payload|
      payload
    end

    assert_equal [0x03, 0x50], PacketHandler.call_handler_for(0x02, 0x03, 0x50)
  end
end
