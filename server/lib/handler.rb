class PacketHandler
  @@handlers = {}

  def self.register_handlers(dispatcher)
    @@handlers.each_key do |action|
      dispatcher.add_handler(action, self)
    end
  end

  def self.unregister_handlers(dispatcher)
    @@handlers.each_key do |action|
      dispatcher.remove_handler(action)
    end
  end

  def self.handle(action_number, &blk)
    @@handlers[action_number] = blk
  end

  def self.call_handler_for(action_number, *args)
    @@handlers[action_number].call(args)
  end

  def self.answer_with(*args)
  end
end