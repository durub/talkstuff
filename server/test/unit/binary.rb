class BinaryTest < Test::Unit::TestCase
  include Binary

  def test_from_string
    assert_equal [0xff, 0x10], from_binary_string("CC", "\xFF\x10")
    assert_equal [6.5, "my string"], from_binary_string("gZ*", "@\xD0\x00\x00my string")
  end

  def test_general
    assert_equal "\xFF", to_binary_string("\xFF")
    assert_equal "\xFF", to_binary_string([255])
    assert_equal "\x00\x80", to_binary_string(32768)
    assert_equal "@\xD0\x00\x00", to_binary_string(6.5)
  end

  def test_string
    assert_equal "\xFF", to_binary_from_string("\xFF")
    assert_equal "\xFF", to_binary_from_string("\xff")
  end

  def test_array
    assert_equal "\xFF", to_binary_from_array([255])
    assert_equal "@\xD0\x00\x00test string\xDB\x10\x00\x80", to_binary_from_array([6.5, "test string", 0xdb, 0x10, 32768])
  end

  def test_fixnum
    assert_equal "\xFF", to_binary_from_fixnum(255)
    assert_equal "\x00\x80", to_binary_from_fixnum(32768)
    assert_equal "\xD0\xDD\x06\x00", to_binary_from_fixnum(450000)
  end

  def test_float
    assert_equal "@\xD0\x00\x00", to_binary_from_float(6.5)
  end

  # unsupported types, like booleans, should evaluate to ""
  def test_unsupported_types
    assert_equal "@\xD0\x00\x00\xFFstring", to_binary_string([6.5, 255, true, false, "string"])
  end
end
