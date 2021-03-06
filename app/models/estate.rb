class Estate
  class << self
    def filter(opts = {})
      # :)
      query = with_rate.
        select(Sequel[:e][:date],
               Sequel[:e][:mur_id],
               Sequel[:e][:rooms],
               Sequel[:e][:address],
               Sequel[:e][:url],
               Sequel.lit('e.total_area / 100 total_area'),
               Sequel.lit('r.rate / 10000 rate'),
               Sequel.lit('e.meter_price / 100 meter_price'),
               Sequel.lit('round(meter_price / rate, 0) meter_price_usd'),
               Sequel.lit('e.price / 100 price'),
               Sequel.lit('round(price / rate, 0) price_usd'),
               Sequel.lit("'USD' as currency")).
        where(Sequel[:e][:date] => max_date_dataset).
        where(Sequel.lit('toInt8(e.rooms) > 0')).
        where { Sequel[:e][:price] > 0 }.
        where { Sequel[:e][:meter_price] > 0 }

      Clickhouse::Client.conn.query(query.sql).to_hashes
    end

    def dataset
      DB[Sequel[:prices][:estate].as(:e)]
    end

    def with_rate
      dataset.join_table('ANY INNER', Sequel.lit('prices.rates r USING (date, currency)'))
    end

    def max_date_dataset
      DB.from(Sequel.lit('prices.estate')).select(Sequel.function(:max, Sequel.lit('date')))
    end

    def history(mur_id)
      q = with_rate.
        where(Sequel[:e][:mur_id] => mur_id).
        select(Sequel[:e][:date],
               Sequel.lit('e.meter_price / 100 meter_price'),
               Sequel.lit('round(meter_price * 10000 / rate, 0) meter_price_usd'),
               Sequel.lit('e.price / 100 price'),
               Sequel.lit('round(price * 10000 / rate, 0) price_usd'),
               Sequel.lit("'USD' as currency"))

      Clickhouse::Client.conn.query(q.sql).to_hashes
    end

    def average_rate
      q = <<~SQL
        SELECT date, round((avg_meter/(rate / 10000))) avg_meter_usd,  round(avg_meter) avg_meter,'USD' AS currency from (
          SELECT date, avg(meter_price) / 100 avg_meter
          FROM prices.estate
          WHERE date = (SELECT max(date) FROM prices.estate)
          GROUP BY date
        ) ANY INNER JOIN prices.rates r USING (date, currency)
      SQL

      execute(q).to_hashes
    end

    def execute(query)
      Clickhouse::Client.conn.query(query)
    end
  end
end
