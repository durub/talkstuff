require 'test/unit'
require 'mocha'
require_relative '../lib/loader'

# Load all lib code
Loader.load_lib

# Run tests
Dir.new(File.dirname(__FILE__) + '/integration').each do |file|
  unless ['.', '..'].include? file
    require_relative 'integration/' + file
  end
end