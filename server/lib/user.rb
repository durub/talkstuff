class User
  attr_reader :socket

  def initialize(session_data = nil)
    @session_data = {}
    @session_data.merge!(session_data) if session_data.kind_of? Hash
  end

  def get(key)
    @session_data[key]
  end

  def set(key, value)
    @session_data[key] = value
  end

  def [](key)
    get(key)
  end

  def []=(key, value)
    set(key, value)
  end

  def unset(key)
    @session_data.delete(key)
  end

  def socket=(socket)
    @socket = socket
    @connected = @socket.nil? ? false : @socket.state == 1 # OPEN = 1?
  end

  def connected?
    @connected
  end
end