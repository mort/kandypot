class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.references :app
      t.string :title, :null => false, :default => ''
      t.text   :body, :null => false, :default => ''
      t.string :category, :null => false, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
