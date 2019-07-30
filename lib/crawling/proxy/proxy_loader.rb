require_relative 'proxy'

module Crawling
  module Proxy
    class ProxyLoader
      class << self
        def from_file(file)
          File.foreach(file).map { |line| Proxy.parse(line) }
        end
      end
    end
  end
end
