require_relative 'e_dostavka'

class HiperMall < EDostavka
  macro_validator :total, :items, :category_name, :price, required: 30_000
  macro_validator :total, :promo_name, required: 30_000
  macro_validator :total, :image, :barcode, required: 25_000
  macro_validator :total, :old_price, required: 5_000, ignore: /\A0.0\z/

  domain     'gipermall.by'
  start_urls 'https://gipermall.by/'
end
