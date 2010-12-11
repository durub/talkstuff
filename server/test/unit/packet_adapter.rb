class PacketAdapterTest < Test::Unit::TestCase
  def setup
    generic = mock("Generic adapter") do
      stubs(:adapt_in).returns("generic")
      stubs(:adapt_out).returns("adapter")
    end

    @adapter = PacketAdapter.new([generic])
  end

  def test_adapt
    assert_equal "generic", @adapter.adapt_in("random data")
    assert_equal "adapter", @adapter.adapt_out("anything")

    second = mock("Second adapter") do
      stubs(:adapt_in).with("generic").returns("adapti")
      stubs(:adapt_out).with("adapter").returns("adapto")
    end

    @adapter.add_adapter(second)
    assert_equal "adapti", @adapter.adapt_in("in")
    assert_equal "adapto", @adapter.adapt_out("out")

    @adapter.remove_adapter(second)
    assert_equal "generic", @adapter.adapt_in("random data")
    assert_equal "adapter", @adapter.adapt_out("anything")
  end

  def test_raw
    @adapter.use_raw
    assert_equal "test string", @adapter.adapt_in("test string")
    assert_equal "raw string", @adapter.adapt_out("raw string")
  end

  def test_not_supported
    unsupported = mock("Useless adapter")
    assert_raise RuntimeError do
      @adapter.add_adapter(unsupported)
    end

    unsupported.stubs(:adapt_in).returns("string")
    assert_raise RuntimeError do
      @adapter.add_adapter(unsupported)
    end

    unsupported = mock("Useless adapter")
    unsupported.stubs(:adapt_out).returns("string")
    assert_raise RuntimeError do
      @adapter.add_adapter(unsupported)
    end
  end

  def test_adapter_stack
    adapter1 = mock("Adapter one") do
      stubs(:adapt_in).returns("one")
      stubs(:adapt_out).returns("one")
    end

    adapter2 = mock("Adapter two") do
      stubs(:adapt_in).returns("two")
      stubs(:adapt_out).returns("two")
    end

    @adapter.push

    @adapter.add_adapter(adapter1)
    assert_equal "one", @adapter.adapt_in("test string")
    assert_equal "one", @adapter.adapt_out("test string")

    @adapter.add_adapter(adapter2)
    @adapter.push

    @adapter.use_raw
    assert_equal "test string", @adapter.adapt_in("test string")
    assert_equal "test string", @adapter.adapt_out("test string")

    @adapter.pop
    assert_equal "two", @adapter.adapt_in("test string")
    assert_equal "two", @adapter.adapt_out("test string")

    @adapter.pop
    assert_equal "generic", @adapter.adapt_in("test string")
    assert_equal "adapter", @adapter.adapt_out("test string")
  end
end