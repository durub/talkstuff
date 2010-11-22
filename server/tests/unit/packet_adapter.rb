class PacketAdapterTest < Test::Unit::TestCase
  def test_raw_adapt
    assert_equal [0xdb, 0x60], PacketAdapter.adapt_in([0xdb, 0x60])
    assert_equal [0xdb, 0x60], PacketAdapter.adapt_out([0xdb, 0x60])
  end

  def test_specific_adapters
    adapter = mock("Custom Adapter") do
      stubs(:adapt_in).returns("adapt")
      stubs(:adapt_out).returns("adapt!")
    end

    PacketAdapter.use_adapter(adapter)
    assert_equal "adapt", PacketAdapter.adapt_in("anything")
    assert_equal "adapt!", PacketAdapter.adapt_out("anything")

    PacketAdapter.use_raw
    assert_equal "anything", PacketAdapter.adapt_in("anything")
    assert_equal "anything", PacketAdapter.adapt_out("anything")
  end

  def test_not_supported
    adapter = mock("Custom Adapter")
    adapter.stubs(:adapt_in)

    assert_raise RuntimeError do
      PacketAdapter.use_adapter(adapter)
    end

    adapter = mock("Custom Adapter")
    adapter.stubs(:adapt_out)

    assert_raise RuntimeError do
      PacketAdapter.use_adapter(adapter)
    end

    assert_raise RuntimeError do
      PacketAdapter.use_adapter(mock("object"))
    end
  end
end

class InstancedPacketAdapterTest < Test::Unit::TestCase
  def setup
    @adapter = PacketAdapter.new

    generic = mock("Generic adapter") do
      stubs(:adapt_in).returns("generic")
      stubs(:adapt_out).returns("adapter")
    end

    @adapter.add_adapter(generic)
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
end