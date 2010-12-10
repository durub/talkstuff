#!/usr/bin/env ruby
require 'em-websocket'
require_relative 'lib/loader.rb'

# Load all the code
Loader.load_lib

# Set $DEVELOPMENT to always true currently
$DEVELOPMENT = true

# Start server
EventMachine.run do
  server = TalkServer.new
  server.start
end