require 'trollop'
require 'colorize'
require 'httparty'
require 'concurrent'

require_relative 'proxy'
require_relative 'proxy_loader'

module Crawling
  module Proxy
    class ProxeChecker
      attr_accessor :queue

      def initialize(opts)
        @threads_count = opts[:threads_count] || 5
        @pool = Concurrent::FixedThreadPool.new(@threads_count)

        @file = opts[:proxy_file]
        @queue = Queue.new
        @mutex = Mutex.new

        @url        = opts[:url]
        @timeout    = opts[:timeout] || 5
        @live_limit = opts[:live_limit]
        @live_file  = opts[:live_file]
        @verbose    = opts[:verbose]

        puts "file: #{@file}, threads: #{@threads_count}"
      end

      def start
        start_time = Time.now.to_i
        ProxyLoader.from_file(@file).each { |proxy| queue << proxy }

        errors          = Concurrent::Array.new
        @processed_jobs = Concurrent::Array.new
        @live_proxies   = Concurrent::Array.new

        Concurrent.global_logger = -> (_level, progname, _message) { @mutex.synchronize { errors << progname; puts [progname.message.red, progname.backtrace].join("\n") } }

        queue.length.times do
          @pool.post do
            begin
              proxy = queue.pop

              tm = Time.now.to_i

              valid = valid_proxy?(proxy)
              tm_e = Time.now.to_i - tm
              proxy.response_time = tm_e

              @live_proxies << proxy if valid
            rescue StandardError => e
              puts e.error

            ensure
              @processed_jobs << proxy
            end
          end
        end

        while true
          puts "#{'Errors'.red}: #{errors.size}, proxies left to check: #{@pool.scheduled_task_count - @pool.completed_task_count}, #{'live:'.green} #{@live_proxies.size}, checked: #{@processed_jobs.size}"

          break if @processed_jobs.size >= (@pool.queue_length + @pool.scheduled_task_count)
          break if @live_file && @live_limit  && @live_proxies.size >= @live_limit

          sleep 1
        end
        @pool.kill
        @pool = nil

        File.write(@live_file, @live_proxies.join("\n"))

        puts "Live file: #{@live_file}".green
        puts "Done in #{(Time.now.to_i - start_time)} secs".green
      end

      def headers
        { "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36" }
      end

      def valid_proxy?(proxy)
        options = {
          http_proxyaddr:   proxy.host,
          http_proxyport:   proxy.port,
          follow_redirects: true,
          timeout:          @timeout,
          headers:          headers
        }

        begin
          response = HTTParty.get(@url, options)

          if response.code >= 200 && response.code < 300
            puts "live proxy #{ proxy }".green if @verbose
            return true
          else
            puts "Bad proxy: #{proxy}" if @verbose
            return false
          end
        rescue => e
          puts "Bad proxy: #{proxy} Error: #{e.message}" if @verbose
          return false
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # bundle exec ruby lib/crawling/proxy/proxy_checker.rb --proxy-file lib/crawling/proxy/proxies2.txt --threads-count 50 --url https://realt.by --timeout 3 --live-limit 5 --live-file lib/crawling/proxy/proxies2_live.txt

  opts = Trollop::options do
    opt :proxy_file, "File with proxies ip:port", type: String
    opt :threads_count, "Threads", type: Integer
    opt :url, "Url to check against", type: String
    opt :timeout, "Request timeout, sec", type: Integer
    opt :live_limit, "Live proxies to collect (about)", type: Integer
    opt :live_file, "Store results into", type: String
    opt :verbose, "Verbose", type: :boolean
  end

  Crawling::Proxy::ProxeChecker.new(opts).start
end
