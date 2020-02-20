module Crawling
  module Proxy
    class Proxy
      attr_accessor :host, :port, :response_time

      class << self
        def parse(str)
          host, port, response_time = str.split(':').map(&:strip)

          Proxy.new(host, port, response_time)
        end

        def from_hash(opts)
          Proxy.new(opts[:host], opts[:port], opts[:response_time])
        end
      end

      def initialize(host, port, response_time = nil)
        @host = host
        @port = port
        @response_time = response_time
      end

      def to_s
        "#{host}:#{port}:#{response_time}"
      end
    end
  end
end
