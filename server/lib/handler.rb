class PacketHandler
  @@handlers = {}

  class << self
    def register_handlers(dispatcher)
      @@handlers.each_key do |action|
        dispatcher.add_handler(action, self)
      end
    end

    def unregister_handlers(dispatcher)
      @@handlers.each_key do |action|
        dispatcher.remove_handler(action)
      end
    end

    def handle(action_number, &blk)
      @@handlers[action_number] = blk
    end

    def call_handler_for(action_number, packet = [], server_data = nil)
      klass = Kernel.const_get(self.name).new

      packet_adapter = server_data[:packet_adapter] if server_data.kind_of? Hash
      packet_adapter ||= PacketAdapter.new

      klass.instance_variable_set :@action_number, action_number
      klass.instance_variable_set :@packet_adapter, packet_adapter
      klass.instance_variable_set :@server, server_data || {}
      if packet.kind_of? Metapacket
        if packet.payload.kind_of?(Hash) || packet.payload.kind_of?(String)
          klass.instance_variable_set :@payload, packet.payload
        else
          klass.instance_variable_set :@payload, Binary.to_binary_string(packet.payload)
        end

        klass.instance_variable_set :@socket, packet.socket
      elsif packet.kind_of? Array
        klass.instance_variable_set :@payload, Binary.to_binary_string(packet)
      elsif packet.kind_of? String
        klass.instance_variable_set :@payload, packet
      end

      klass.instance_eval &@@handlers[action_number]
    end
  end

  def initialize(magic_number = nil)
    @socket, @payload = nil
    @magic_number = magic_number.nil? ? 0xdb : magic_number
    #                                    |
    #                                    ---------> Default protocol magic number
    #                                               Change it freely (0x00-0xff)
  end

  # answer_with
  #
  # Binary:
  # * Reads :protocol_magic_number (optional), if it's a byte, it changes the protocol magic number in the data variable, originally determined
  # by the PacketDispatcher. If it's false, it excludes the protocol magic number from the data variable. If it's not entered, it maintains the
  # original PacketDispatcher magic_number. :protocol_magic_number gets deleted from the *args Hash.
  # * Reads :action_number and deletes it from the *args Hash. If it's not present, it's calculated as (ActionNumberBeingHandled + 1). If it
  # should be different from that, you must explicity define it.
  # * Reads :payload and deletes it from the *args Hash. Then, it gets appended to the data variable.
  # * Reads any other data present in the *args Hash, discards the key and appends the value to the data variable.
  # * Adapts the data (packet adapters)
  # * Sends the data variable to the user
  #
  # JSON:
  # * Reads :protocol_magic_number (the priority, which means that it shadows :protocol_number) OR :protocol_number
  # * Reads :action_number.  If it's not present, it's calculated as (ActionNumberBeingHandled + 1). If it
  # should be different from that, you must explicity define it.
  # * Transforms the remaining Hash into a JSON string
  # * Sends the JSON string to the user
  def answer_with(hash)
    if hash.kind_of?(Hash) && !hash[:json]
      data = Binary.to_binary_from_array([protocol_magic_number, action_number + 0x01])
      index = 1

      # Read protocol magic number
      magic_number = hash[:protocol_magic_number]

      hash.delete(:protocol_magic_number)
      if magic_number == false
        data.slice!(0)
        index = 0
      elsif magic_number.kind_of? Fixnum
        data[0] = Binary.to_binary_from_fixnum(magic_number)
      end

      # Read action_number
      _action_number = hash[:action_number]

      hash.delete(:action_number)
      data[index] = Binary.to_binary_string(_action_number) unless _action_number.nil?

      # Read payload
      _payload = hash[:payload]
      hash.delete(:payload)

      data << Binary.to_binary_string(_payload) unless _payload.nil?

      # Read all the other data
      hash.each_value do |value|
        data << Binary.to_binary_string(value)
      end

      data = @packet_adapter.adapt_out(data) unless @packet_adapter.nil?
    elsif hash[:json]
      json = {}
      json[:protocol_number] = protocol_magic_number
      json[:action_number] = action_number + 0x01

      data = hash.clone
      data.delete(:json)
      data[:protocol_number] = data.delete(:protocol_magic_number) if data.include?(:protocol_magic_number)
      json.merge!(data)

      @packet_adapter.push
      @packet_adapter.use_raw
      @packet_adapter.add_adapter(TJSONAdapter)
      data = @packet_adapter.adapt_out(json)
      @packet_adapter.pop
    end

    socket.send data unless socket.nil?
    data
  end

  # accessors
  attr_reader :payload, :socket, :action_number, :server
  def protocol_magic_number
    @magic_number
  end
end