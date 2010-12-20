class TalkServer < Server
  def init_data
    @server_data[:user_list] = UserList.new
    @server_data[:admin_keys] = ["test_key"]
  end

  def init_adapters(adapter_manager)
    adapter_manager.add_adapter(TJSONAdapter)
  end
end
