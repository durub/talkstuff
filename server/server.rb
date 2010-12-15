#!/usr/bin/env ruby
require 'em-websocket'
require_relative 'lib/loader.rb'

# Load all the code
Loader.load_lib

# Start server
EventMachine.run do
  config = ServerConfig.load("config/server.yml")

  config.each_server do |server_name, server_config|
    klass = Kernel.const_get(camelize(server_name))
    server = klass.new(server_config)

    server.start
  end
end