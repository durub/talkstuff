class DispatcherHandlerIntegrationTest < Test::Unit::TestCase
  def setup
    PacketHandler.handle 0x01 do
      "return string"
    end

    PacketHandler.handle 0x02 do
      [payload, socket]
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
    socket = mock("Socket")
    packet = Metapacket.new([0x00, 0x01, 65, 66, 67], socket)

    assert @dispatcher.has_handler_for? 0x01
    assert_equal "return string", @dispatcher.handle(packet)

    packet[1] = 0x02
    assert_equal [packet.payload[2..-1].pack("C*"), socket], @dispatcher.handle(packet)

    PacketHandler.unregister_handlers(@dispatcher)

    assert !@dispatcher.has_handler_for?(0x01)
    assert_raise RuntimeError do
      @dispatcher.handle(packet)
    end
  end
end