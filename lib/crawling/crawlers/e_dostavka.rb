require_relative '../parser_base'

class EDostavka < ParserBase
  domain     'e_dostavka.by'
  start_urls 'https://e-dostavka.by/'

  debug_mode true

  macro_validator :total, :items, :category_name, :price, required: 13_000
  macro_validator :total, :promo_name, required: 13_000
  macro_validator :total, :image, :barcode, required: 13_000
  macro_validator :total, :old_price, required: 2_000, ignore: /\A0.0\z/

  def parse(response, data = {})
    response[:doc].xpath("//ul[contains(@class,'catalog_menu_visible')]/li/a").to_a.uniq { |a| a[:href] }.each do |a|
      yield({ url: full_url(a[:href]), method: :get, callback: :parse_category, follow_redirects: true, max_level: 2, data: data })
    end
  end

  def parse_category(response, data)
    response[:doc].xpath("//ul[@class='catalog_submenu']/li/a").each do |a|
      yield({ url: full_url(a[:href]), method: :get, callback: :parse_subcategory, follow_redirects: true, max_level: 2, data: data })
    end
  end

  def parse_subcategory(response, data)
    response[:doc].xpath("//li[@class='catalog_menu-item selected']/ul/li/a").each do |a|
      yield({ url: full_url(a[:href]), method: :get, callback: :parse_list, data: data })
    end
  end

  def parse_list(response, data)
    response[:doc].xpath("//div[contains(@class,'products_card')]//form").each do |product_block|
      parse_product(product_block, response[:url])
    end

    if next_step?(response[:doc])
      steep = response[:url][/lazy_steep/] ? (response[:url][/lazy_steep=(\d+)/, 1].to_i + 1) : 2
      next_page_param = response[:url][/page=(\d+)/, 1]
      next_page_param = next_page_param ? "&page=#{next_page_param}" : ''

      yield({ url: full_url("#{response[:url].sub(/\?.*/, "")}?lazy_steep=#{steep}#{next_page_param}"), method: :get, callback: :parse_list, data: data })
    else
      next_page = response[:doc].at_xpath("//div[contains(@class,'navigation')]//a[@class='next_page_link']")
      yield({ url: full_url(next_page[:href]), method: :get, callback: :parse_list, data: data }) if next_page
    end
  end

  def parse_product(product_block, category_url)
    product = {}

    product[:category_name] = product_block.xpath("//div[@class='breadcrumbs']//text()").map(&:text).delete_if { |el| el =~ /Каталог товаров/ }.join(' *** ')
    product[:category_url]  = category_url
    product[:product_name]  = product_block.xpath("div[@class='title']/a").text
    product[:url]           = product_block.xpath("div[@class='img']/a/@href").text
    product[:image]         = product_block.xpath("div[@class='img']/a/img/@src").text
    product[:barcode]       = product[:image][/thumbs\/\d+\/(\d+)/, 1] || ''
    product[:barcode]       = product[:barcode].size == 13 ? product[:barcode] : ''
    product[:code]          = product[:url][/item_(\d+)/, 1]
    product[:price]         = product_block.xpath("div//div[@class='price_byn']/div[@class='price']").text
    product[:old_price]     = product_block.xpath("div//div[@class='price_byn']/div[@class='price']/div[contains(@class,'old_price')]").text
    product[:promo_name]    = product_block.xpath(".//div[@class='item_info']//div[contains(@class,'sale_block')]/div[@class='value']").text.strip
    product[:promo_name]    = product_block.xpath(".//div[@class='stickers']/div[contains(@class, 'sticker')]/@title").text if product[:promo_name].empty?
    product[:promo_name]    = product_block.xpath(".//div[@class='stickers']/div[contains(@class, 'sticker')]/@title").text if product[:promo_name].empty?
    product[:mur_id]        = MurmurHash3::V32.str_hash(product[:code])

    save_product(product)
  end

  def next_step?(doc)
    !doc.xpath("//a[@class='show_more']").empty?
  end
end
