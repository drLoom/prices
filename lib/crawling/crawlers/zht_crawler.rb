require_relative '../parser_base'

class ZhtCrawler < ParserBase
  domain     'zht.by'
  start_urls 'http://zht.by/'

  debug_mode true
  macro_validator :total, :items, :category_name, :price, required: 5_000
  macro_validator :total, :promo_name, required: 2_000
  macro_validator :total, :image, :barcode, required: 4_500
  macro_validator :total, :old_price, required: 4_000, ignore: /\A0.0\z/

  def parse(response, data = {})
    response[:doc].xpath("//div[@class='child cat_menu']//li/a").each do |a|
      sleep 1
      yield({ url: full_url(a[:href]), method: :get, callback: :parse_category, data: data })
    end
  end

  def parse_category(response, data)
    response[:doc].xpath("//div[contains(@class, 'articles-list')]/section//div[@class='item-title']/a").each do |a|
      sleep 1
      yield({ url: full_url(a[:href]), method: :get, callback: :parse_subcategory, data: data })
    end
  end

  def parse_subcategory(response, data)
    response[:doc].xpath("//div[contains(@class,'catalog')]//div[@class='catalog_item_wrapp']").each do |product_block|
      parse_product(product_block)
    end

    next_page = response[:doc].at_xpath("(//ul[@class='flex-direction-nav']/li[@class='flex-nav-next ']/a[@class='flex-next'])[1]")
    yield({ url: full_url(next_page[:href]), method: :get, callback: :parse_subcategory, data: data }) if next_page
  end

  def parse_product(product_block)
    product = {}

    breadcrumbs = product_block.xpath("//div[@class='container']/div[@class='breadcrumbs']//a[@class='number']")
    product[:category_name] = breadcrumbs.map(&:text).map(&:strip).join(' *** ')
    product[:category_url]  = full_url(breadcrumbs.last.xpath('./@href').text)
    product[:product_name]  = product_block.xpath(".//div[@class='item_info']/div[@class='item-title']/a/@title").text.strip
    product[:url]           = full_url(product_block.xpath(".//div[@class='item_info']/div[@class='item-title']/a/@href").text)
    product[:image]         = full_url(product_block.xpath(".//div[contains(@class,'image_wrapper_block')]/a//img/@src").text)
    product[:barcode]       = product[:image][/\/(\d+)\./, 1] || ''
    product[:code]          = product_block.xpath("./div[contains(@class,'catalog_item item_wrap')]/@id").text.strip
    product[:price]         = product_block.xpath(".//div[@class='item_info']//div[@class='price']").text.strip
    product[:old_price]     = product_block.xpath(".//div[@class='item_info']//div[contains(@class,'price discount')]/strike").text.strip
    product[:promo_name]    = product_block.xpath(".//div[@class='item_info']//div[contains(@class,'sale_block')]/div[contains(@class, 'value')]").text.strip
    product[:promo_name]    = product_block.xpath(".//div[@class='stickers']/div[contains(@class, 'sticker')]/@title").text if product[:promo_name].empty?
    product[:mur_id]        = MurmurHash3::V32.str_hash(product[:code])

    save_product(product)
  end
end
