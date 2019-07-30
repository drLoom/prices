require_relative '../parser_base'

class RealtBy < ParserBase
  domain     'realt.by'
  start_urls 'https://realt.by/'

  debug_mode true

  validator :presence, :url, :code, :ad_created_at, :price, :city, :rooms
  validator :string, :rooms, verbose: true, regexp: /\A\d+\z/

  macro_validator :total, :items,  required: 6_000
  macro_validator :total, :errors, required: 0, less: true

  def start
    browser = nil
    valid_proxy   = nil
    proxies.each do |proxy|
      begin
        browser = setup_capybara(app_host: 'https://realt.by/sale/flats/search/?search=all', proxy: proxy)

        browser.visit 'https://realt.by/sale/flats/search/?search=all'
        browser.find(:xpath, "//select[contains(@name, 'town_id')]/option[contains(text(), 'Минск')]").select_option
        browser.find(:xpath, "//a[@id='search-list']").click
        sleep 2

        valid_proxy = proxy
        puts "valid_proxy: #{valid_proxy.host}:#{valid_proxy.port}".green
        break
      rescue Exception => e
        puts e.message
        puts e.backtrace

        browser = nil
        sleep 0.5
      end
    end

    yield({ url: (browser.current_url + '&view=0'), method: :get, callback: :parse_category, headers: headers, proxy: valid_proxy })
  end

  def parse_category(response, data)
    0.upto(response[:doc].xpath("(//div[@class='uni-paging']/span/span/a)[1]").text.strip.to_i) do |i|
      yield({ url: (response[:url] + "&page=#{i}"), method: :get, callback: :parse_subcategory, headers: headers, proxy: response[:proxy] })
    end
  end

  def parse_subcategory(response, data)
    response[:doc].xpath("//div[@class='bd-table']/div[contains(@class,'bd-table-item')]").each do |flat_block|
      parse_flat(flat_block, response)
    end
  end

  def parse_flat(flat_block, response)
    flat = {}

    flat[:page_url]      = response[:url]

    flat[:url]           = flat_block.xpath("./div/div[@class='ad']/a/@href").text
    flat[:code]          = flat[:url][/object\/(\d+)/, 1]
    flat[:ad_created_at] = Date.parse(flat_block.xpath(".//div[@class='date']/span/text()").text).strftime('%Y-%m-%d')
    flat[:updated_at]    = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    flat[:price]         = get_price_from_block(flat_block)

    flat[:meter_price]   = get_meter_price_from_block(flat_block)
    flat[:city]          = 'Минск'

    rooms = flat_block.xpath("./div[@class='bd-table-item-header']/div[1]").text.strip
    return if rooms[/\Aк/] # комнаты

    rooms = rooms.split('/').map(&:strip).first

    flat[:rooms]         = rooms
    flat[:house_year]    = flat_block.xpath("./div[@class='bd-table-item-header']/div[6]").text.to_i
    street               = flat_block.xpath("./div/div[@class='ad']/a/@title").text

    flat[:street], flat[:house] = separate_house_and_street(street)
    flat[:address]              = build_address(flat[:city], flat[:street], flat[:house])

    areas = flat_block.xpath("./div[@class='bd-table-item-header']/div[5]").text.split('/').map{ |area| parse_str_to_float(area) }
    flat[:total_area], flat[:living_room], flat[:kitchen_area] = areas

    flat[:mur_id] = MurmurHash3::V32.str_hash(flat[:code] + flat[:address])

    save_entity(flat)
  end

  def headers
    { "User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:43.0) Gecko/20100101 Firefox/43.0" }
  end

  def build_address(city, street, house)
    "#{city.strip} ~> #{street.strip} ~>  #{house.strip}".strip.gsub(/~>$/, '').gsub(/^~>\s/, '')
  end

  def parse_str_to_float(str)
    str.strip.sub(',', '.').to_f if str
  end

  def get_meter_price_from_block(flat_block)
    price_part = flat_block.xpath("./div/div[@class='cena']/span[contains(@class,'price')][2]").text
    unless price_part.empty?
      price_part.gsub!(/[[:space:]]/, '')
      price_part = price_part.scan(/\d+,?\d+/)[0]
      parse_str_to_float(price_part)
    else
      nil
    end
  end

  def get_price_from_block(flat_block)
    price_part = flat_block.xpath("./div/div[@class='cena']/span[contains(@class,'price')][1]").text
    unless price_part.empty?
      price_part.gsub!(/[[:space:]]/, '')
      price_part.sub!(/млнруб/, '000000')
      price_part = price_part.scan(/\d+,?\d+/)[0]
      parse_str_to_float(price_part)
    else
      0.0
    end
  end

  def separate_house_and_street(street)
    street, house = street.split('., ')
    [street, house || '']
  end
end

# bundle exec ruby lib/crawling/super_viser.rb -p realt_by_crawler -t 1 --proxy-file lib/crawling/proxy/proxies2_live.txt