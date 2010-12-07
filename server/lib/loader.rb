module Loader
  module_function

  def load_lib
    Dir.new(File.dirname(__FILE__)).each do |file|
      unless ['.', '..'].include? file
        load File.dirname(__FILE__) + '/' + file
      end
    end
  end

  def load_handlers(dispatcher = nil)
    each_handler do |handler|
      handler.register_handlers(dispatcher) if dispatcher
    end
  end

  # also loads each handler file
  def each_handler
    Dir.new(File.dirname(__FILE__) + '/../handlers').each do |file|
      unless ['.', '..'].include? file
        load File.dirname(__FILE__) + '/../handlers/' + file

        yield Kernel.const_get(file.capitalize[0..-4] << "Handler")
      end
    end
  end
end