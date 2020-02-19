require 'trollop'
require 'active_support/all'
require 'csv'
require 'yaml'
require 'colorize'

module DomainTools
  class TextarBrakebook
    def initialize(opts)
    end

    def start
      search_codes = CSV.read('/data/prices/inputs/textar_brakebook/REQUESTS.csv')
      search_results = File.read('/data/prices/textar_brakebook/textar_brakebook.yaml').split(/---/).reject(&:blank?).map { |chunk| YAML.load(chunk.strip) }

      found = search_results.map { |i| i[:search_number] }.uniq
      total = search_codes.map(&:last).map(&:strip).uniq
      not_found = total - found

      file = '/data/prices/inputs/textar_brakebook/not_found.csv'
      CSV.open(file, 'wb') do |csv|
        not_found.each { |code| csv << [code] }
      end

      puts "Total: #{total.size}".green
      puts "Not found: #{not_found.size}".red
      puts "Found: #{found.size}".green
      puts '/data/prices/inputs/textar_brakebook/not_found.csv'.green
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  opts = Trollop::options do
    # opt :parser, "Parser file", type: String
    # opt :threads_count, "Worker threads count", type: Integer
    # opt :proxy_file, "File with proxies", type: String
    # opt :verbose, "Verbose", type: TrueClass
  end

  DomainTools::TextarBrakebook.new(opts).start
end

# bundle exec ruby lib/crawling/domain_tools/textar_brakebook.rb
