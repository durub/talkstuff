require 'yaml'

class ServerConfig
  def self.load(file)
    file.kind_of?(File) ? ServerConfig.new(YAML::load(file)) : ServerConfig.new(YAML::load(File.new(file)))
  end

  def initialize(config)
    @config = config
  end

  def each_server(&blk)
    @config.each_pair(&blk)
  end
end