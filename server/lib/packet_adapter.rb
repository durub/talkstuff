class PacketAdapter
  @@adapter = nil

  def self.adapt_in(data)
    return data unless @@adapter
    @@adapter.adapt_in(data)
  end

  def self.adapt_out(data)
    return data unless @@adapter
    @@adapter.adapt_out(data)
  end

  def self.use_adapter(adapter)
    raise "Adapter not supported" unless adapter.respond_to?(:adapt_in) && adapter.respond_to?(:adapt_out)
    @@adapter = adapter
  end

  def self.use_raw
    @@adapter = nil
  end
end