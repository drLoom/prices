Sequel.migration do
  change do
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:users) do
      primary_key :id
      column :email, "text", :default=>"", :null=>false
      column :encrypted_password, "text", :default=>"", :null=>false
      column :remember_created_at, "timestamp without time zone"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      index [:email], :unique=>true
    end
  end
end
              Sequel.migration do
                change do
                  self << "SET search_path TO \"$user\", public"
                  self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190728100414_create_ch_prices.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190728104217_create_ch_estate.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190729093538_create_ch_rates.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20190731205311_devise_create_users.rb')"
                end
              end
