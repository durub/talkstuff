class Metapacket
  attr_accessor :payload, :socket, :protocol_number, :action_number

  def initialize(payload = [], socket = nil)
    if payload.kind_of? Hash
      @protocol_number = payload[:protocol_number]
      @action_number = payload[:action_number]
    else
      @protocol_number = payload[0]
      @action_number = payload[1]
    end

    @payload = payload
    @socket = socket
    @stripped = false
  end

  def [](index)
    if !@stripped
      return @protocol_number if index == 0
      return @action_number   if index == 1
    end

    @payload[index]
  end

  def []=(index, value)
    @payload[index] = value
    read_meta
  end

  def strip_meta_from_payload!
    if !@stripped
      read_meta

      if @payload.kind_of? Hash
        @payload.delete(:protocol_number)
        @payload.delete(:action_number)
      else
        @payload = @payload[2..-1]
      end

      @stripped = true
    end

    self
  end

  def adapt(adapter)
    self.clone.adapt!(adapter)
  end

  def adapt!(adapter)
    @payload = adapter.adapt_in(@payload)
    @payload = @payload.unpack("C*") unless @payload.kind_of? Hash
    read_meta

    self
  end

  def clone
    Metapacket.new(@payload.clone, @socket)
  end

  private
    def read_meta
      return nil if @stripped

      if @payload.kind_of? Hash
        @protocol_number = @payload[:protocol_number]
        @action_number   = @payload[:action_number]
      else
        @protocol_number = @payload[0]
        @action_number   = @payload[1]
      end
    end
end
