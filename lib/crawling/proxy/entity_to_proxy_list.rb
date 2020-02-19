require 'trollop'
require 'csv'
require 'colorize'

require_relative '../../data_storage'

module Crawling
  module Proxy
    class EntityToProxyList
      attr_accessor :entity_file, :file

      def initialize(opts = {})
        @entity_file = opts[:entity_file]
        @file = opts[:file]
      end

      def run
        CSV.open(file, 'wb') do |csv|
          DataStorage.get_data_from_file(entity_file).each do |entity|
            next if entity[:ip].blank?

            csv << ["#{entity[:ip]}:#{entity[:port]}"]
          end
        end

        puts "#{file}".green
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # bundle exec ruby lib/crawling/proxy/entity_to_proxy_list.rb --entity-file /data/prices/free_proxy_list_net/2019-08-30/free_proxy_list_net.yaml --file lib/crawling/proxy/proxies.txt

  opts = Trollop::options do
    opt :entity_file, "File with downloaded prxies", type: String
    opt :file, "output file", type: String
  end

  Crawling::Proxy::EntityToProxyList.new(opts).run
end