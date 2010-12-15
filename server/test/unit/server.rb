require 'em-websocket'
require 'socket'

class ServerTest < Test::Unit::TestCase
  def test_initialize
    # defaults
    server = Server.new
    assert_equal "0.0.0.0", server.ip
    assert_equal 8080, server.port
    assert_equal false, server.debug

    # specifics
    server = Server.new({:bind_ip => "1.2.3.4", :port => 8040, :development => false})
    assert_equal "1.2.3.4", server.ip
    assert_equal 8040, server.port
    assert_equal false, server.debug

    # debug
    assert_equal true, TalkServer.new({:development => true}).debug
  end

  # This code sucks
  # README: if you're getting a "no acceptor exception", it may be
  # that the current port being used (port variable) is already in
  # use by another application. in that case, you should change it.
  # 1024-65535 if not running as root
  def test_run_and_stop_server
    port = 32753

    EventMachine.run do
      server = Server.new({:bind_ip => "0.0.0.0", :port => 32753})
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
    server = Server.new({:bind_ip => "0.0.0.0", :port => 8080})
    handler = mock("Handler")

    handler.expects(:register_handlers).with do |dispatcher|
      dispatcher.respond_to?(:add_handler)
    end

    server.register_handler(handler)
  end

  def test_registering_adapters
    manager = mock("Adapter manager")

    manager.stubs(:add_adapter).with do |klass|
      klass.respond_to?(:adapt_in) && klass.respond_to?(:adapt_out)
    end

    Server.new.init_adapters(manager)
  end

  private
    def open_and_close_connection(host, port)
      TCPSocket.open(host, port).close
    end

    def done
      EventMachine.stop
    end
end