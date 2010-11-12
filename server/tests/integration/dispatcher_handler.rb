class DispatcherHandlerIntegrationTest < Test::Unit::TestCase
  def setup
    PacketHandler.handle 0x01 do
      "return string"
    end

    @dispatcher = PacketDispatcher.new(0x00)
  end

  def test_integration_normal
    PacketHandler.register_handlers(@dispatcher)

    assert @dispatcher.has_handler_for? 0x01
    assert_equal "return string", @dispatcher.handle([0x00, 0x01])

    PacketHandler.unregister_handlers(@dispatcher)

    assert !@dispatcher.has_handler_for?(0x01)
    assert_raise RuntimeError do
      @dispatcher.handle([0x00, 0x01])
    end
  end

  def test_integration_metapacket
    PacketHandler.register_handlers(@dispatcher)
    packet = Metapacket.new([0x00, 0x01], mock("Socket"))

    assert @dispatcher.has_handler_for? 0x01
    assert_equal "return string", @dispatcher.handle(packet)

    PacketHandler.unregister_handlers(@dispatcher)

    assert !@dispatcher.has_handler_for?(0x01)
    assert_raise RuntimeError do
      @dispatcher.handle(packet)
    end
  end
end