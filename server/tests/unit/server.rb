require 'em-websocket'
require 'socket'

class TalkServerTest < Test::Unit::TestCase
  def test_initialize
    # defaults
    server = TalkServer.new
    assert_equal "0.0.0.0", server.ip
    assert_equal 8080, server.port
    assert_equal false, server.debug

    # specifics
    server = TalkServer.new("1.2.3.4", 8040, false)
    assert_equal "1.2.3.4", server.ip
    assert_equal 8040, server.port
    assert_equal false, server.debug

    # debug
    assert_equal true, TalkServer.new("", 0, true).debug
  end

  # This code sucks
  # README: if you're getting a "no acceptor exception", it may be
  # that the current port being used (port variable) is already in
  # use by another application. in that case, you should change it.
  # 1024-65535 if not running as root
  def test_run_and_stop_server
    port = 32753

    EventMachine.run do
      server = TalkServer.new("0.0.0.0", port)
      server.start

      # to run after server is started
      EventMachine.next_tick do
        assert_nothing_raised do
          open_and_close_connection("localhost", port)
        end

        server.stop

        # to run after server is closed
        EventMachine.next_tick do
          assert_raise Errno::ECONNREFUSED do
            open_and_close_connection("localhost", port)
          end

          done
        end
      end
    end
  end

  def test_register_handlers
    server = TalkServer.new("0.0.0.0", 8080)
    handler = mock("Handler")

    handler.expects(:register_handlers).with do |dispatcher|
      dispatcher.respond_to?(:add_handler)
    end

    server.register_handler(handler)
  end

  private
    def open_and_close_connection(host, port)
      TCPSocket.open(host, port).close
    end

    def done
      EventMachine.stop
    end
end