require 'test/unit'
require 'mocha'

# Load all lib code
Dir.new(File.dirname(__FILE__) + '/../lib').each do |file|
  unless ['.', '..'].include? file
    require_relative '../lib/' + file
  end
end

# Run tests
Dir.new(File.dirname(__FILE__) + '/integration').each do |file|
  unless ['.', '..'].include? file
    require_relative 'integration/' + file
  end
end