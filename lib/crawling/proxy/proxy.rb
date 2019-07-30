module Crawling
  module Proxy
    class Proxy
      attr_accessor :host, :port

      class << self
        def parse(str)
          host, port = str.split(':').map(&:strip)

          Proxy.new(host, port)
        end

        def from_hash(opts)
          Proxy.new(opts[:host], opts[:port])
        end
      end

      def initialize(host, port)
        @host = host
        @port = port
      end

      def to_s
        "#{host}:#{port}"
      end
    end
  end
end
