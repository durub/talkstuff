require 'test/unit'

Dir.chdir(File.dirname(__FILE__)) do
  Dir.glob("*.rb").each do |file|
    require_relative file unless file == "test.rb"
  end
end