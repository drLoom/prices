require 'lib/crawling/crawl'

class CrawlerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(opts = {})
    Crawling::Crawl.new(opts).start
  end
end
