require 'test/unit'
require 'mocha'
require_relative '../lib/loader'

# Load all lib code
Loader.load_lib

# Run tests
Dir.new(File.dirname(__FILE__) + '/unit').each do |file|
  unless ['.', '..'].include? file
    require_relative 'unit/' + file
  end
end