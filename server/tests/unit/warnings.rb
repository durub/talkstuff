class WarningsTest < Test::Unit::TestCase
  def test_suppress_warnings
    ret = ""

    with_warnings_suppressed do
      ret = warning_generator
    end

    assert_equal "", ret
  end

  def test_restore_state
    ret = ""

    with_warnings_suppressed do
      ret = warning_generator
    end

    assert_equal "", ret
    assert_match /warning: already initialized constant MONKEY/, warning_generator
  end

  private
    def warning_generator
      IO.popen('-') do |io|
        if io
          return io.read
        else
          $stderr.reopen($stdout)
          Object.const_set('MONKEY', 1)
          Object.const_set('MONKEY', 2)
        end
      end
    end
end