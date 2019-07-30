Sequel.migration do
  up do
    query = <<-SQL
      CREATE TABLE IF NOT EXISTS prices.estate
      (
          date          Date,
          domain        String,
          code          String,
          mur_id        UInt32,
          price         UInt64,
          meter_price   UInt64,
          rooms         String,
          ad_created_at Date,
          url           String,
          address       String,
          city          String,
          street        String,
          house         String,
          total_area    UInt16,
          living_room   UInt16,
          kitchen_area  UInt16,
          house_year    UInt16,
          
          timestamp    DateTime
      ) ENGINE = ReplacingMergeTree(date, (date, domain, mur_id), 8192)
    SQL

    Clickhouse::Client.conn.execute query
  end

  down do
    Clickhouse::Client.conn.execute "DROP table IF EXISTS prices.estate"
  end
end
