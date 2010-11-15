module Loader
  module_function

  def load_lib
    Dir.new(File.dirname(__FILE__)).each do |file|
      unless ['.', '..'].include? file
        require_relative file
      end
    end
  end

  def load_handlers(dispatcher = nil)
    Dir.new(File.dirname(__FILE__) + '/../handlers').each do |file|
      unless ['.', '..'].include? file
        require_relative '../handlers/' + file
        Kernel.const_get(file.capitalize[0..-4] << "Handler").register_handlers(dispatcher) if dispatcher
      end
    end
  end
end