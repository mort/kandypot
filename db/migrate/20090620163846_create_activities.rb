class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      
      t.with_options :null => false do |c| 
        t.string :credentials_app_token
        t.string :credentials_signature
        t.string :member_token
        t.string :content_token
        t.string :content_owner_member_token
        t.string :subject
        t.string :content_type
        t.string :content_source
        t.string :ip, :limit => 15
        t.datetime :activity_at
      end
      
      t.datetime :processed_at
      t.integer  :proccessing_status, :limit => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
