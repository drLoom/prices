require 'crawling/crawl'
require 'loaders/estate_loader'
require 'data_storage'
require 'crawling/proxy/entity_to_proxy_list'
require 'crawling/proxy/proxy_checker'

class RealtByWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform(opts = {})
    Crawling::Crawl.new(parser: 'free_proxy_list_net', threads_count: 1, verbose: true).start
    downloaded_proxy_file = DataStorage.today_entity_path('free_proxy_list_net')

    FileUtils.mkdir_p '/data/prices/proxies/'
    proxy_file = '/data/prices/proxies/realt_by.txt'
    proxy_live = '/data/prices/proxies/realt_by_live.txt'
    Crawling::Proxy::EntityToProxyList.new(entity_file: downloaded_proxy_file, file: proxy_file).run

    Crawling::Proxy::ProxeChecker.new(proxy_file: proxy_file, threads_count: 5, url: 'https://realt.by', timeout: 5, live_limit: 30, live_file: proxy_live).start

    opts[:proxy_file] = proxy_live

    Crawling::Crawl.new(opts.symbolize_keys).start

    parser = opts['parser']

    Loaders::EstateLoader.new(file: DataStorage.today_entity_path(parser)).load_data
  end
end
