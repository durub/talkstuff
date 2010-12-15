class Server
  attr_reader :ip, :port, :debug

  def initialize(config = {})
    # transform all keys into strings
    config = config.inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end

    # initialize
    @packet_adapter = PacketAdapter.new
    @dispatcher = PacketDispatcher.new(config["protocol_number"] || 0xdb)
    @server_data = ServerData.new
    init_data
    init_adapters(@packet_adapter)

    @server_data[:packet_adapter] = @packet_adapter
    @signature = nil

    @ip = config["bind_ip"] || "0.0.0.0"
    @port = config["port"] || 8080
    @debug = config["development"] || false
  end

  # meant to be overriden
  def init_data
  end

  # meant to be overriden
  def init_adapters(adapter_manager)
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
      rescue
        print "Unknown exception: \n", $!, "\n" if debug
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
      if @debug
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