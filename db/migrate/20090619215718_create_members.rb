class CreateMembers < ActiveRecord::Migration
  
  def self.up
    create_table :members do |t|
      t.references :app

      t.string  :member_token, :default => '', :null => false
      t.integer :deposits_count,  :default => 0, :null => false     
      t.integer :transfers_count, :default => 0, :null => false 
      t.integer :kandies_count, :default => 0, :null => false
      t.integer :kandy_ownerships_count, :default => 0, :null => false
      
      t.timestamps
    end

    add_index(:members, :member_token, :unique => true)
  end

  def self.down
    drop_table :members
  end
end
