module Binary
  module_function

  def from_binary_string(format, string)
    string.unpack(format)
  end

  def to_binary_string(object)
    return to_binary_from_array (object) if object.kind_of? Array
    return to_binary_from_fixnum(object) if object.kind_of? Fixnum
    return to_binary_from_float (object) if object.kind_of? Float
    return to_binary_from_string(object) if object.kind_of? String
  end

  def to_binary_from_array(array)
    binary = ""

    array.each do |element|
      binary << to_binary_string(element)
    end

    binary
  end

  def to_binary_from_fixnum(fixnum)
    return [fixnum].pack("C") if fixnum - 255 <= 0
    return [fixnum].pack("S") if fixnum - 65536 < 0
    [fixnum].pack("L")
  end

  # TODO: FIXME
  # This server needs to communicate with javascript
  # Therefore, we need to verify that the floats are compatible
  def to_binary_from_float(float)
    [float].pack("g")
  end

  def to_binary_from_string(string)
    string
  end
end