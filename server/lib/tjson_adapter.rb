require 'json'

class TJSONAdapter
  def self.adapt_in(data)
    return data if data[0..4] != "TJSON"

    data.slice!(0..4)

    begin
      JSON.parse(data, :symbolize_names => true)
    rescue JSON::ParserError
      {}
    end
  end

  def self.adapt_out(data)
    begin
      json = JSON.generate(data)
      json != "{}" ? "TJSON" + json : ""
    rescue JSON::GeneratorError
      ""
    end
  end
end
