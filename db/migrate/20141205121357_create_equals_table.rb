require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(:equals) do
      primary_key :id
      String :host, null: false
      inet :ip, null: false
      integer :ttl, default: 86_400
      boolean :written, default: false
      timestamptz :created
      timestamptz :updated
      foreign_key :user_id, :users
      index :host, unique: true
    end
    pgt_created_at(:equals, :created)
    pgt_updated_at(:equals, :updated)
  end

  down do
    drop_table(:equals)
  end
end
