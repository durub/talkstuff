require 'test/unit'
require 'mocha'
require_relative '../lib/loader'

# Load all lib code
Loader.load_lib

# Load Handlers Helper
require_relative 'helpers/handlers_helper.rb'

# Load all handlers
Loader.load_handlers

# Run tests
Dir.new(File.dirname(__FILE__) + '/handlers').each do |file|
  unless ['.', '..'].include? file
    require_relative 'handlers/' + file
  end
end