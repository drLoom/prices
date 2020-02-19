require_relative '../parser_base'

class FreeProxyListNet < ParserBase
  start_urls 'https://free-proxy-list.net/'
  debug_mode true

  validator :presence, :ip, :port

  macro_validator :total, :items, required: 250

  def parse(response, data = {})
    response[:doc].xpath("//table[@id='proxylisttable']//tr").drop(1).each do |row|
      tds = row.xpath('td').map { |td| td.text.strip }

      proxy = {
        ip:      tds[0],
        port:    tds[1].to_i,
        country: tds[3],
        https:   (tds[6].to_s.downcase == 'yes')
      }

      proxy[:mur_id] = MurmurHash3::V32.str_hash("#{proxy[:ip]}#{proxy[:port]}")

      save_entity(proxy)
    end
  end
end

# bundle exec ruby lib/crawling/crawl.rb -p free_proxy_list_net -t 1 -v
