require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    create_table(:a_records) do
      primary_key :id
      String :host, null: false
      inet :ip, null: false
      integer :ttl, default: 86_400
      boolean :written, default: false
      timestamptz :created
      timestamptz :updated
      foreign_key :user_id, :users
      index [:host, :ip], unique: true
    end
    pgt_created_at(:a_records, :created)
    pgt_updated_at(:a_records, :updated)
  end

  down do
    drop_table(:a_records)
  end
end
