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