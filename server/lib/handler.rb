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

    # TODO: FIXME (see pack)
    def call_handler_for(action_number, packet = [])
      klass = Kernel.const_get(self.name).new

      if packet.kind_of? Metapacket
        klass.instance_variable_set :@payload, packet.payload
        klass.instance_variable_set :@socket, packet.socket
      elsif packet.kind_of? Array
        klass.instance_variable_set :@payload, packet.pack("C*") rescue nil
      elsif packet.kind_of? String
        klass.instance_variable_set :@payload, packet
      end

      klass.instance_eval &@@handlers[action_number]
    end
  end

  def answer_with(*args)
  end

  def payload
    @payload
  end

  def socket
    @socket
  end
end