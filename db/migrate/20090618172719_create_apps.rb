class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|

      t.with_options :length => 100, :null => false do |c|
        t.string :name 
        t.string :nicename   
        t.string :url
        t.string :app_key
        t.string :app_token
      end

      t.string :ip, :limit => 15

      t.text :description

      t.integer :members_count, :default => 0, :null => false
      t.integer :kandies_count, :default => 0, :null => false

      t.integer :status, :limit => 2, :default => 1, :null => false

      t.timestamps
    end

    add_index(:apps, :name, :unique => true)    
    add_index(:apps, :nicename, :unique => true)    
    add_index(:apps, :url, :unique => true)    
    add_index(:apps, :app_key, :unique => true)    
    add_index(:apps, :app_token, :unique => true)    
    add_index(:apps, :ip, :unique => true)    
    
  end

  def self.down
    drop_table :apps
  end
end
