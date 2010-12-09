class PacketAdapter
  def initialize(adapters = [])
    @adapters = []

    adapters.each do |adapter|
      add_adapter(adapter)
    end
  end

  def adapt_in(data)
    @adapters.each do |adapter|
      data = adapter.adapt_in(data)
    end

    data
  end

  def adapt_out(data)
    @adapters.each do |adapter|
      data = adapter.adapt_out(data)
    end

    data
  end

  def add_adapter(adapter)
    raise "Adapter not supported" unless adapter.respond_to?(:adapt_in) && adapter.respond_to?(:adapt_out)
    @adapters << adapter
  end


  def remove_adapter(adapter)
    @adapters.delete adapter
  end

  def use_raw
    @adapters = []
  end
end