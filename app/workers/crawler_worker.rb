require 'crawling/crawl'
require 'loaders/estate_loader'
require 'loaders/rate_loader'
require 'data_storage.rb'

class CrawlerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(opts = {})
    Crawling::Crawl.new(opts.symbolize_keys).start

    parser = opts['parser']
    loader = case parser
             when /nbrb/
               Loaders::RateLoader
             when /realt/
               Loaders::EstateLoader
             else
               raise "Unknown parser: #{parser.inspect}"
             end

    loader.new(file: DataStorage.today_entity_path(parser)).load_data
  end
end
