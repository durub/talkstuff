require 'em-websocket'

EventMachine.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    ws.onopen do
    end
    
    ws.onmessage do |message|
      ws.send message
    end
    
    ws.onclose do
    end
  end
end