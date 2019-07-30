Sequel.migration do
  up do
    Clickhouse::Client.conn.execute "CREATE DATABASE IF NOT EXISTS prices"
  end

  down do
    Clickhouse::Client.conn.execute "DROP DATABASE prices"
  end
end
