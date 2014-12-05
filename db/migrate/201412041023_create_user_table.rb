require 'sequel'

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :secret
      String :email
    end
  end

  down do
    drop_table(:users)
  end
end
