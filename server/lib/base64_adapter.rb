require 'base64'

class Base64Adapter
  # Base64 module adds some unnecessary line breaks, we have to remove them
  def self.adapt_in(data)
    Base64.decode64(data).gsub("\n", '')
  end

  def self.adapt_out(data)
    Base64.encode64(data).gsub("\n", '')
  end
end
