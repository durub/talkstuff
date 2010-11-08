class DispatcherTest < Test::Unit::TestCase
  def setup
    @generic_handler = mock("My Mock Handler") do
      stubs(:call_handler_for).returns("test string")
    end

    @dispatcher = PacketDispatcher.new(0x00)
  end

  def test_handler_management
    @dispatcher.add_handler(0x01, @generic_handler)
    assert @dispatcher.has_handler_for?(0x01)

    @dispatcher.remove_handler(0x01)
    assert !@dispatcher.has_handler_for?(0x01)
  end

  def test_handler_calling
    @dispatcher.add_handler(0x01, @generic_handler)
    assert_equal "test string", @dispatcher.handle([0x00, 0x01])
  end

  def test_magic_number
    @dispatcher.add_handler(0x01, @generic_handler)

    assert_raise RuntimeError do
      @dispatcher.handle([0xff, 0x01])
    end
  end

  def test_no_handler
    assert_raise RuntimeError do
      @dispatcher.handle([0x00, 0x01])
    end
  end
end