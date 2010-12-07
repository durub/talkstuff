class HandlerTest < Test::Unit::TestCase
  def test_handling
    PacketHandler.handle 0x01 do
      "handle it"
    end

    assert_equal "handle it", PacketHandler.call_handler_for(0x01)

    PacketHandler.handle 0x02 do
      payload
    end

    PacketHandler.handle 0x03 do
      [payload, socket]
    end

    # different data types
    # [0x03, 0x50] array -> binary string
    assert_equal "\x03P", PacketHandler.call_handler_for(0x02, [0x03, 0x50])

    metapacket = Metapacket.new
    metapacket = mock("Metapacket") do
      stubs(:socket).returns("SocketObject")
      stubs(:kind_of?).with(Metapacket).returns(true)
      stubs(:kind_of?).with(Array).returns(false)
      stubs(:kind_of?).with(String).returns(false)
    end

    metapacket.stubs(:payload).returns("\x03P")
    assert_equal ["\x03P", "SocketObject"], PacketHandler.call_handler_for(0x03, metapacket), "Binary string -> binary string failed"

    metapacket.stubs(:payload).returns([0x03, 0x50])
    assert_equal ["\x03P", "SocketObject"], PacketHandler.call_handler_for(0x03, metapacket), "Array -> binary string failed"

    metapacket.stubs(:payload).returns({ :key => :value, :john => :doe })
    assert_equal [{:key => :value, :john => :doe}, "SocketObject"], PacketHandler.call_handler_for(0x03, metapacket), "Hash -> Hash failed"
  end

  def test_answer_with
    @handler = PacketHandler.new(0x00)
    @handler.instance_variable_set :@action_number, 0x10

    assert_equal "\x00\x11\x03\x50", @handler.answer_with(:payload => [0x03, 0x50])
    assert_equal "\x00\x11mix datatypes\xFF\x30\x20\x10\x43\x00\x80\x00",
                 @handler.answer_with(:payload => ["mix datatypes", 0xff, [0x30, 0x20, 0x10], 128.5])
    assert_equal "\x00\x11payload_1_2_3", @handler.answer_with(:payload => "payload", :_1 => "_1", :_2 => "_2", :_3 => "_3")

    @handler = PacketHandler.new(0x05)
    @handler.instance_variable_set :@action_number, 0x14
    assert_equal "\x05\x15user\x00password", @handler.answer_with(:user => ["user", 0x00], :pass => "password")
    assert_equal "\x00\x10data", @handler.answer_with(:protocol_magic_number => 0x00, :action_number => 0x10, :string => "data")
    assert_equal "\x20data!", @handler.answer_with(:protocol_magic_number => false, :action_number => 0x20, :string => "data!")
  end

  def test_answer_with_sockets
    socket = mock("Socket")
    socket.expects(:send_data).with do |data|
      data == "\x00\x11data..."
    end

    @handler = PacketHandler.new(0x00)
    @handler.instance_variable_set :@action_number, 0x10
    @handler.instance_variable_set :@socket, socket

    assert_equal "\x00\x11data...", @handler.answer_with(:data => "data...")
  end
end