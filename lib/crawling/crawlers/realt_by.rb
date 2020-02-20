require_relative '../parser_base'

class RealtBy < ParserBase
  start_urls 'https://realt.by/?eID=tx_uedbcore_mapApi&tid=1&R=0&type=count&hash=3251352f988fb017062b7a6158611ee5&s%5Btown_id%5D%5Be%5D=5102&tx_uedbflat_pi2%5Brec_per_page%5D=30&tx_uedbflat_pi2%5Basc_desc%5D%5B0%5D=0&tx_uedbflat_pi2%5Basc_desc%5D%5B1%5D=0'

  debug_mode true

  validator :presence, :url, :code, :ad_created_at, :price, :city, :rooms
  validator :string, :rooms, verbose: true, regexp: /\A\d+\z/

  macro_validator :total, :items, required: 5_000
  macro_validator :total, :errors, required: 0, less: true

  def start
    proxy = proxies.sort_by { |p| p.response_time.to_i }.first
    yield({ url: 'https://realt.by/sale/flats/search/', method: :get, callback: :parse_form, proxy: proxy })
  end

  def parse_form(response, data = {})
    hash = response[:doc].xpath("//*[@id='secret-hash']/@value").text.strip
    yield({ url: "https://realt.by/?eID=tx_uedbcore_mapApi&tid=1&R=0&type=count&hash=#{hash}&s%5Btown_id%5D%5Be%5D=5102&tx_uedbflat_pi2%5Brec_per_page%5D=30&tx_uedbflat_pi2%5Basc_desc%5D%5B0%5D=0&tx_uedbflat_pi2%5Basc_desc%5D%5B1%5D=0",
            method: :get, callback: :parse, headers: headers, proxy: response[:proxy] })
  end

  def parse(response, data = {})
    search_param = JSON(response[:doc].text)
    puts "To download #{search_param['count']}".green

    yield({ url: "https://realt.by/sale/flats/?search=#{search_param['search']}&view=0", method: :get, callback: :parse_category, proxy: response[:proxy] })
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

    flat[:page_url] = response[:url]

    flat[:url]  = flat_block.xpath("./div/div[@class='ad']/a/@href").text
    flat[:code] = flat[:url][/object\/(\d+)/, 1]

    flat[:ad_created_at] = Date.parse(flat_block.xpath(".//div[@class='date']/span/text()").text).strftime('%Y-%m-%d')
    flat[:updated_at]    = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    flat[:price]         = get_price_from_block(flat_block)

    flat[:meter_price] = get_meter_price_from_block(flat_block)
    flat[:city]        = 'Минск'

    rooms = flat_block.xpath("./div[@class='bd-table-item-header']/div[1]").text.strip
    return if rooms[/\Aк/] # комнаты

    rooms = rooms.split('/').map(&:strip).first

    flat[:rooms]      = rooms
    flat[:house_year] = flat_block.xpath("./div[@class='bd-table-item-header']/div[6]").text.to_i
    street            = flat_block.xpath("./div/div[@class='ad']/a/@title").text

    flat[:street], flat[:house] = separate_house_and_street(street)
    flat[:address]              = build_address(flat[:city], flat[:street], flat[:house])

    areas                                                      = flat_block.xpath("./div[@class='bd-table-item-header']/div[5]").text.split('/').map { |area| parse_str_to_float(area) }
    flat[:total_area], flat[:living_room], flat[:kitchen_area] = areas

    flat[:mur_id] = MurmurHash3::V32.str_hash(flat[:code] + flat[:address])

    save_entity(flat)
  end

  def headers
    { "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36" }
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
    return 0.0 if price_part.empty?

    price_part.gsub!(/[[:space:]]/, '')

    if price_part[/млн/]
      price_part.sub!(/,/, '.')
      price_part.sub!(/млнруб/, '')
      price_part.to_f * 1_000_000
    else
      price_part = price_part.scan(/\d+,?\d+/)[0]
      parse_str_to_float(price_part)
    end
  end

  def separate_house_and_street(street)
    street, house = street.split('., ')
    [street, house || '']
  end
end

# bundle exec ruby lib/crawling/crawl -p realt_by_crawler -t 1 --proxy-file lib/crawling/proxy/proxies2_live.txt -v