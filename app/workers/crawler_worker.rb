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
               RateLoader
             when /realt/
               EstateLoader
             else
               raise "Unknown parser: #{parser.inspect}"
             end

    "Loaders::#{loader}".constantize.new(file: DataStorage.today_entity_path(parser)).load_data
  end
end
