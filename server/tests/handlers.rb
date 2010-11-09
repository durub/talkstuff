require 'test/unit'
require 'mocha'

# Load all lib code
Dir.new(File.dirname(__FILE__) + '/../lib').each do |file|
  unless ['.', '..'].include? file
    require_relative '../lib/' + file
  end
end

# Load Handlers Helper
require_relative 'helpers/handlers_helper.rb'

# Load all handlers
Dir.new(File.dirname(__FILE__) + '/../handlers').each do |file|
  unless ['.', '..'].include? file
    require_relative '../handlers/' + file
  end
end


# Run tests
Dir.new(File.dirname(__FILE__) + '/handlers').each do |file|
  unless ['.', '..'].include? file
    require_relative 'handlers/' + file
  end
end