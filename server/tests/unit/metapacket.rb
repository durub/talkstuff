class MetapacketTest < Test::Unit::TestCase
  def test_initialization
    assert_equal [0x60, 0x32], Metapacket.new([0x60, 0x32]).payload

    socket = mock("Socket")
    packet = Metapacket.new([0x30, 0x16], socket)

    assert_equal [0x30, 0x16], packet.payload
    assert_equal socket, packet.socket
  end

  def test_accessors
    packet = Metapacket.new([0x73, 0x57])
    packet[2] = 0xff

    assert_equal 0x73, packet[0]
    assert_equal 0xff, packet[2]
  end

  def test_adapt
    assert_equal [0xdb, 0x01], Metapacket.new("\xdb\x01").adapt
  end
end