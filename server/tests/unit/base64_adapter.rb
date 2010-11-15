class Base64AdapterTest < Test::Unit::TestCase
  def test_adapt
    assert_equal "dGVzdCBzdHJpbmc=", Base64Adapter.adapt_out("test string")
    assert_equal "test string", Base64Adapter.adapt_in("dGVzdCBzdHJpbmc=")
  end
end