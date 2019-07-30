require 'nokogiri'
require 'httparty'

class Crawler
  def fetch(opts = {})
    url     = opts[:url]
    headers = opts[:headers] ? opts[:headers] : {}
    method  = opts[:method]  ? opts[:method] : 'get'

    case method
      when :get
        get(url, headers, opts)
      else
        raise "Not implemented method #{method.inspect}"
    end
  end

  def get(url, headers = {}, opts = {})
    begin
      retries ||= 0

      options = {
        follow_redirects: false,
        timeout: 10,
        headers: headers
      }

      if opts[:proxy]
        options[:http_proxyaddr] = opts[:proxy].host
        options[:http_proxyport] = opts[:proxy].port
      end

      result = HTTParty.get(url, options)

      case result.code
        when 200...300
          job_result = { url: url, doc: Nokogiri::HTML(result.response.body), body: result.response.body }
          job_result.merge!(proxy: opts[:proxy]) if opts[:proxy]
          job_result
        when 300...400
          level = opts[:level].to_i

          if opts[:follow_redirects] && level < opts[:max_level]
            return get(result.headers['location'], headers, opts.merge(level: (level + 1)))
          end
        else
          raise "Unknown response code: #{result.code}, url: #{url}"
      end

    rescue Exception => e
      puts "****url: #{url} ----------try ##{retries + 1}\n"
      retry if (retries += 1) < 5
    end
  end
end
