class ActivityModifications < ActiveRecord::Migration
  def self.up
    # add_column :activities, :uuid, :string, :limit => 36  
    # change_column :activities, :activity_type, :verb, :string
    # change_column :activities, :content_type, :object_type, :string
    # change_column :activities, :content_url, :object_url, :string
    
    #drop_table :activities
    
    create_table :activities, :force => true do |t|
      
      t.references(:app)
      
      t.datetime :processed_at
      t.integer  :proccessing_status, :limit => 2
      
      t.string :ip, :limit => 15, :null => false # server-side
      t.string :category, :limit => 25, :null => false # server-side
      t.string :uuid, :limit => 36, :null => false # server-side
      
      t.datetime :published, :null => false

      t.string :actor_token, :limit => 32, :null => false
      
      t.string :verb, :null => false
      
      t.string :object_type
      t.string :object_url
            
      t.string :target_type
      t.string :target_token, :limit => 32
      t.string :target_url
      
      t.string :target_author_token, :limit => 32
      
      
      
      t.string :mood, :limit => 25
      t.integer :intensity, :limit => 2
      
      
      t.timestamps
    end
    
    
    
    
  end

  def self.down
    drop_table :activities
  end
end
