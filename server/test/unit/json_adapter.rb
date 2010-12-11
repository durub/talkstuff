class TJSONAdapterTest < Test::Unit::TestCase
  def test_adapt_in
    # should return data itself (a identity function) when string doesn't begins
    # with "TJSON"
    assert_equal "", TJSONAdapter.adapt_in("")
    assert_equal "{}", TJSONAdapter.adapt_in("{}")

    # should work properly
    assert_equal ({ :string => "test" }), TJSONAdapter.adapt_in("TJSON{\"string\":\"test\"}")
    assert_equal ({ :another => "string",
                    :truth => true,
                    :falsity => false,
                    :number => 50000,
                    :float => 8.5}),
                    TJSONAdapter.adapt_in("TJSON{\"another\":\"string\",\"truth\":true,\"falsity\":false,\"number\":50000,\"float\":8.5}")

    # should return a empty hash as expression is malformed (going to cause a parser error)
    assert_equal ({}), TJSONAdapter.adapt_in("TJSON{parse_error}")
  end

  def test_adapt_out
    # should return "" when expression is empty
    assert_equal "", TJSONAdapter.adapt_out({})

    # should return TJSON appended with the json data when data is valid
    assert_equal "TJSON{\"string\":\"hehe\"}", TJSONAdapter.adapt_out({ :string => "hehe" })
    assert_equal "TJSON{\"param\":\"one\",\"param2\":2}", TJSONAdapter.adapt_out({ :param => "one", :param2 => 2})
    assert_equal "TJSON{\"bool\":true,\"!bool\":false}", TJSONAdapter.adapt_out({:bool => true, "!bool" => false})

    # should return "" when the generator can't unparse an object or something like that happens
    object = mock("Generic object, no json capabilities")
    assert_equal "", TJSONAdapter.adapt_out(object)
  end
end