require_relative 'warnings.rb'

module Loader
  module_function

  def load_lib
    Dir.new(current_dir).each do |file|
      unless ['.', '..'].include? file
        load_ruby current_dir + '/' + file
      end
    end

    load_ruby current_dir + '/../app/server.rb'
  end

  def load_handlers(dispatcher = nil)
    each_handler do |handler|
      handler.register_handlers(dispatcher) if dispatcher
    end
  end

  # also loads each handler file
  def each_handler
    Dir.new(current_dir + '/../app/handlers').each do |file|
      unless ['.', '..'].include? file
        load_ruby current_dir + '/../app/handlers/' + file

        yield Kernel.const_get(file.capitalize[0..-4] << "Handler")
      end
    end
  end

  def load_ruby(file)
    with_warnings_suppressed do
      load file
    end
  end

  def current_dir
    File.dirname(__FILE__)
  end
end
