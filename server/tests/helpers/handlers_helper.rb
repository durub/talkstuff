class HandlerTest < Test::Unit::TestCase
  def should_answer_with(*args)
    get_handler_class.any_instance.expects(:answer_with).with() do |*block_args|
      assert_equal args, block_args
    end
  end

  def call_handler_for(action_number, payload = [])
    get_handler_class.call_handler_for(action_number, payload)
  end

  def get_handler_name
    self.class.name[0..-5] + "Handler"
  end

  def get_handler_class
    Kernel.const_get(get_handler_name)
  end
end