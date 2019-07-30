Sequel.migration do
  change do
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
  end
end
              Sequel.migration do
                change do
                  self << "SET search_path TO \"$user\", public"
                  self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190728100414_create_ch_prices.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190728104217_create_ch_estate.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190729093538_create_ch_rates.rb')"
                end
              end
