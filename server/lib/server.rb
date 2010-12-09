class TalkServer
  attr_reader :ip, :port, :debug

  def initialize(ip = "0.0.0.0", port = 8080, debug = false)
    @packet_adapter = PacketAdapter.new
    @dispatcher = PacketDispatcher.new(0xdb)
    @server_data = ServerData.new
    @server_data[:user_list] = UserList.new

    @ip, @port, @debug = ip, port, $DEVELOPMENT || debug
    @signature = nil
  end

  def start
    load_handlers

    @signature ||= EventMachine::WebSocket.start(:host => @ip, :port => @port, :debug => @debug, &method(:event_dispatcher))
  end

  def stop
    EventMachine.stop_server(@signature) if @signature
    @signature = nil
  end

  def register_handler(handler)
    handler.register_handlers(@dispatcher)
  end

  private
    def on_open(socket)
    end

    def on_message(socket, message)
      begin
        packet = Metapacket.new(message, socket).adapt!(@packet_adapter)

        @dispatcher.handle(packet, @server_data)
      rescue RuntimeError
        print "Dispatcher::handle exception: ", $!, "\n" if @debug
      end
    end

    def on_close(socket)
      #user = @server_data[:user_list].get_user_by_socket(socket)
      #@server_data.delete(user) unless user.nil?
    end

    def on_open_development(socket)
      reload_code
      on_open(socket)
    end

    def on_message_development(socket, message)
      reload_code
      on_message(socket, message)
    end

    def on_close_development(socket)
      reload_code
      on_close(socket)
    end

    # don't call event dispatcher directly
    # it's supposed to be used as a "callback"
    def event_dispatcher(socket)
      if $DEVELOPMENT
        socket.onopen do
          on_open_development(socket)
        end

        socket.onmessage do |message|
          on_message_development(socket, message)
        end

        socket.onclose do
          on_close_development(socket)
        end
      else
        socket.onopen do
          on_open(socket)
        end

        socket.onmessage do |message|
          on_message(socket, message)
        end

        socket.onclose do
          on_close(socket)
        end
      end
    end

    def reload_code
      Loader.load_lib
      load_handlers
    end

    def load_handlers
      Loader.each_handler do |handler|
        register_handler(handler)
      end
    end
end