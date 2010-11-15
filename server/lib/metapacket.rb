class Metapacket
  attr_accessor :payload, :socket

  def initialize(payload = [], socket = nil)
    @payload = payload
    @socket = socket
  end

  def [](index)
    @payload[index]
  end

  def []=(index, value)
    @payload[index] = value
  end

  def adapt
    @payload = PacketAdapter.adapt_in(@payload).unpack("C*")
  end
end