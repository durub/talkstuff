class DispatcherHandlerIntegrationTest < Test::Unit::TestCase
  def test_integration
    PacketHandler.handle 0x01 do
      "return string"
    end

    dispatcher = PacketDispatcher.new(0x00)
    PacketHandler.register_handlers(dispatcher)

    assert dispatcher.has_handler_for? 0x01
    assert_equal "return string", dispatcher.handle([0x00, 0x01])

    PacketHandler.unregister_handlers(dispatcher)

    assert !dispatcher.has_handler_for?(0x01)
    assert_raise RuntimeError do
      dispatcher.handle([0x00, 0x01])
    end
  end
end