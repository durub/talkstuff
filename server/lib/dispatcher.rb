class PacketDispatcher
  attr_reader :magic_number

  def initialize(magic_number)
    @handlers = {}
    @magic_number = magic_number
  end

  def add_handler(action_number, handler)
    Array(action_number).each do |number|
      @handlers[number] = handler
    end
  end

  def remove_handler(action_number)
    Array(action_number).each do |number|
      @handlers.delete(number)
    end
  end

  def has_handler_for?(action_number)
    @handlers.has_key?(action_number)
  end

  def handle(packet)
    raise "Packet does not match protocol magic number" unless packet[0] == @magic_number
    raise "Handler does not exist for this packet type" unless has_handler_for?(packet[1])
    @handlers[packet[1]].call_handler_for(packet[1], packet[2..-1])
  end
end