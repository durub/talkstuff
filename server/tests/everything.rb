require 'test/unit'

Dir.new(File.dirname(__FILE__)).each do |file|
  unless ['.', '..', 'README', 'everything.rb'].include? file
    require_relative file
  end
end