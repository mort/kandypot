class CreateKandyOwnerships < ActiveRecord::Migration
  def self.up
    create_table :kandy_ownerships do |t|
      t.references :member
      t.references :kandy
      t.integer :status, :null => false, :default => 1, :limit => 1
      t.datetime :expired_at
      t.timestamps
    end
  end

  def self.down
    drop_table :kandy_ownerships
  end
end
