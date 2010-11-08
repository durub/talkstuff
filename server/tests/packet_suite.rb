require 'test/unit'
require 'mocha'

# lib/ dependencies
['dispatcher', 'handler'].each do |file|
  require_relative "../lib/#{file}"
end

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