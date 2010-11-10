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

    def call_handler_for(action_number, payload = [])
      klass = Kernel.const_get(self.name).new
      klass.instance_variable_set :@payload, payload
      klass.instance_eval &@@handlers[action_number]
    end
  end

  def answer_with(*args)
  end

  def payload
    @payload
  end
end