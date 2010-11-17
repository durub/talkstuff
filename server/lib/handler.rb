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

    def call_handler_for(action_number, packet = [])
      klass = Kernel.const_get(self.name).new

      klass.instance_variable_set :@action_number, action_number
      if packet.kind_of? Metapacket
        klass.instance_variable_set :@payload, Array(packet.payload).pack("C*")
        klass.instance_variable_set :@socket, packet.socket
      elsif packet.kind_of? Array
        klass.instance_variable_set :@payload, packet.pack("C*") rescue nil
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
  # * Reads :protocol_magic_number (optional), if it's a byte, it changes the protocol magic number in the data_string, originally determined
  # by the PacketDispatcher. If it's false, it excludes the protocol magic number from the data_string. If it's not entered, it maintains the
  # original PacketDispatcher magic_number. Anyway, :protocol_magic_number gets deleted from the *args Hash.
  # * Reads :action_number and deletes it from the *args Hash. If it's not present, it's calculated as (ActionNumberBeingHandled + 1). If it
  # should be different from that, you must explicity define it.
  # * Reads :payload and deletes it from the *args Hash. Then, it gets appended to the data_string.
  # * Reads any other data present in the *args Hash, discards the key and appends the value to the data_string.
  # * Send the data_string to the user
  def answer_with(hash)
    data_string = Binary.to_binary_from_array([protocol_magic_number, action_number + 0x01])
    index = 1

    if hash.kind_of? Hash
      # Read protocol magic number
      magic_number = hash[:protocol_magic_number]

      hash.delete(:protocol_magic_number)
      if magic_number == false
        data_string.slice!(0)
        index = 0
      elsif magic_number.kind_of? Fixnum
        data_string[0] = Binary.to_binary_from_fixnum(magic_number)
      end

      # Read action_number
      _action_number = hash[:action_number]

      hash.delete(:action_number)
      data_string[index] = Binary.to_binary_string(_action_number) unless _action_number.nil?

      # Read payload
      _payload = hash[:payload]
      hash.delete(:payload)

      data_string << Binary.to_binary_string(_payload) unless _payload.nil?

      # Read all the other data
      hash.each_value do |value|
        data_string << Binary.to_binary_string(value)
      end
    end

    socket.send_data data_string unless socket.nil?
    data_string
  end

  def payload
    @payload
  end

  def socket
    @socket
  end

  def action_number
    @action_number
  end

  def protocol_magic_number
    @magic_number
  end
end