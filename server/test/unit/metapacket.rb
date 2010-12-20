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
    assert_equal 0xff, packet.payload[2]
  end

  def test_adapt
    adapter = mock("Generic Adapter") do
      stubs(:adapt_in).returns("\xdb\x01")
    end

    packet = Metapacket.new("\xdb\x01")
    assert_equal [0xdb, 0x01], packet.adapt(adapter).payload
    assert_not_equal [0xdb, 0x01], packet.payload
    assert_not_equal packet, packet.adapt(adapter)
    assert_equal packet, packet.adapt!(adapter)
    assert_equal [0xdb, 0x01], packet.payload
  end

  def test_adapt_hash
    adapter = mock("JSON Adapter") do
      stubs(:adapt_in).returns({ :string => "hi", :number => 50 })
    end

    packet = Metapacket.new("TJSON{\"string\":\"hi\",\"number\":50}")
    assert_equal ({:string => "hi", :number => 50}), packet.adapt(adapter).payload
    assert_not_equal ({:string => "hi", :number => 50}), packet.payload
    assert_not_equal packet, packet.adapt(adapter)
    assert_equal packet, packet.adapt!(adapter)
    assert_equal ({:string => "hi", :number => 50}), packet.payload
  end

  def test_adapt_should_read_meta
    adapter = mock("JSON Adapter") do
      stubs(:adapt_in).returns({ :protocol_number => 0x10, :action_number => 0x00, :string => "hi", :number => 50 })
    end

    packet = Metapacket.new({ :protocol_number => 0x00, :action_number => 0x10 })
    assert_equal 0x00, packet.protocol_number
    assert_equal 0x10, packet.action_number
    assert_equal 0x10, packet.adapt(adapter).protocol_number
    assert_equal 0x00, packet.adapt(adapter).action_number

    packet.adapt!(adapter)
    assert_equal 0x10, packet.protocol_number
    assert_equal 0x00, packet.action_number
  end

  def test_special
    packet = Metapacket.new({ :protocol_number => 0x30, :action_number => 0x60, :anything => "string" })

    assert_equal 0x30, packet.protocol_number
    assert_equal 0x60, packet.action_number
    assert_equal 0x30, packet[0]
    assert_equal 0x60, packet[1]
  end

  def test_hash
    socket = mock("Socket")
    packet = Metapacket.new({ :key => "value", :ponies => "unicorns" }, socket)

    assert_equal "value", packet.payload[:key]
    assert_equal "unicorns", packet.payload[:ponies]
    assert_equal "value", packet[:key]
    assert_equal "unicorns", packet[:ponies]
  end

  def test_strip
    packet = Metapacket.new({ :protocol_number => 0x30, :action_number => 0x60, :anything => "string" })

    assert_not_nil packet.payload[:protocol_number]
    assert_not_nil packet.payload[:action_number]

    packet.strip_meta_from_payload!

    assert_nil packet.payload[:protocol_number]
    assert_nil packet.payload[:action_number]

    assert_equal 0x30, packet.protocol_number
    assert_equal 0x60, packet.action_number
    assert_nil packet[0]
    assert_nil packet[1]
  end
end
