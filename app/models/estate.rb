class Estate
  class << self
    def filter(opts = {})
      query = <<~SQL
      SELECT e.date,
             e.mur_id,
             e.rooms,
             e.address,
             e.total_area / 100 total_area,
             e.url,
             'USD' AS currency,
             r.rate / 10000 rate,
             e.meter_price / 100 meter_price,
             round(meter_price / rate, 1) meter_price_usd,
             e.price / 100 price,
             round(price / rate, 2) price_usd
        FROM prices.estate e ANY
               INNER JOIN prices.rates r USING (date, currency)
        WHERE date = (SELECT max(date) FROM prices.estate) 
              and toInt8(e.rooms) > 0
              and e.price > 0
              and e.meter_price > 0
        SETTINGS join_use_nulls = 1

      SQL
      Clickhouse::Client.conn.query(query).to_hashes
    end
  end
end
