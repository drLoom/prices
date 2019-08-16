require 'crawling/crawl'
require 'loaders/estate_loader'
require 'data_storage.rb'

class CrawlerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(opts = {})
    Crawling::Crawl.new(opts.symbolize_keys).start
    Loaders::EstateLoader.new(DataStorage.today_entity_path(opts['parser'])).load_data
  end
end
