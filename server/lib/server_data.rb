class ServerData
  def initialize(data = {})
    @server_data = {}
    @server_data.merge!(data)
  end

  def get(key)
    @server_data[key]
  end

  def set(key, value)
    @server_data[key] = value
  end

  def [](key)
    get(key)
  end

  def []=(key, value)
    set(key, value)
  end
end
