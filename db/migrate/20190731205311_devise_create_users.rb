Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id

      String :email, :null => false, :default => ""
      String :encrypted_password, :null => false, :default => ""

      ## Rememberable
      DateTime :remember_created_at

      DateTime :created_at
      DateTime :updated_at
    end

    alter_table(:users) do
      add_index :email, :unique => true
    end
  end
end
