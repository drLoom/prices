Sequel.migration do
  up do
    query = <<-SQL
      CREATE TABLE IF NOT EXISTS prices.rates
      (
        date     Date,
        currency String,
        rate     UInt64
      ) ENGINE = Join(ANY, INNER, date, currency)
    SQL

    Clickhouse::Client.conn.execute query
  end

  down do
    Clickhouse::Client.conn.execute "DROP table IF EXISTS prices.rates"
  end
end
