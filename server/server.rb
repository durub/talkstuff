require 'em-websocket'
require_relative 'lib/loader.rb'

# Load all the code
Loader.load_lib

# Initialize dispatcher
$dispatcher = PacketDispatcher.new(0xdb)

# Load and register handlers
Loader.load_handlers($dispatcher)

# Adapter
PacketAdapter.use_adapter(Base64Adapter)

# Debug
if $DEBUG || ARGV[0] == "debug"
  $RELOAD = true
end

# Start server
EventMachine.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen do
    end

    ws.onmessage do |message|
      # Reload all code if debugging
      if $RELOAD
        $dispatcher.instance_eval { @handlers = {} } # some evil metaprogramming to clean up handlers

        Loader.load_lib
        Loader.load_handlers($dispatcher)
        PacketAdapter.use_adapter(Base64Adapter)
      end

      begin
        $dispatcher.handle(Metapacket.new(message, ws).adapt)
      rescue
        print "handle exception: ", $!, "\n"
      end
    end

    ws.onclose do
    end
  end
end