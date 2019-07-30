require 'thread'
require 'trollop'
require 'concurrent'
require 'active_support/all'

require_relative 'worker'
require_relative 'proxy/proxy_loader'

module Crawling
  class Crawl
    attr_accessor :queue

    def initialize(opts)
      @mutex = Mutex.new
      @queue = Queue.new
      @threads_count = opts[:threads_count] || 5

      load "./lib/crawling/crawlers/#{opts[:parser]}.rb"
      crawler_opts = {}
      crawler_opts[:proxies] = Proxy::ProxyLoader.from_file(opts[:proxy_file]) if opts[:proxy_file]

      @parser_class = opts[:parser].camelize.constantize
      @parser = @parser_class.new(crawler_opts)

      @pool = Concurrent::FixedThreadPool.new(@threads_count)

      puts "Parser: #{@parser_class}, threads_count: #{@threads_count}".green
      @verbose = opts[:verbose]
    end

    def start
      start_time = Time.now.to_i
      @parser.clear_today_downloaded

      @parser.start { |job| queue << job } # entry point

      errors         = Concurrent::Array.new
      processed_jobs = Concurrent::Array.new

      Concurrent.global_logger = -> (_level, progname, _message) { @mutex.synchronize { errors << progname; puts [progname.message.red, progname.backtrace].join("\n") } }

      @pool.post { Worker.new(@pool, @parser_class, queue.pop, processed_jobs).do_job }

      while true
       puts "Errors: #{errors.size}, @pool.queue_length: #{@pool.queue_length}, scheduled_task_count: #{@pool.scheduled_task_count}, completed_task_count: #{@pool.completed_task_count}, processed_jobs: #{processed_jobs.size}, @pool.length: #{@pool.length}" if @verbose

        break if processed_jobs.size >= (@pool.queue_length + @pool.scheduled_task_count)

        sleep 5
      end
      @pool.shutdown

      unless @pool.wait_for_termination 5
        raise 'Cant terminate'
      end
      @pool = nil

      puts "Done in #{(Time.now.to_i - start_time)} secs"
      @parser.final_stats

      raise 'Cant process next' if errors.any?
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  opts = Trollop::options do
    opt :parser, "Parser file", type: String
    opt :threads_count, "Worker threads count", type: Integer
    opt :proxy_file, "File with proxies", type: String
    opt :verbose, "Verbose", type: TrueClass
  end

  Crawling::Crawl.new(opts).start
end

# bundle exec ruby lib/crawling/crawl.rb -p realt_by_crawler -t 1 --proxy-file lib/crawling/proxy/proxies2_live.txt
