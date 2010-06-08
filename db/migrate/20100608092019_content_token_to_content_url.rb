class ContentTokenToContentUrl < ActiveRecord::Migration
  def self.up
    change_column :activities, :content_token, :text
    rename_column :activities, :content_token, :content_url
  end

  def self.down
    change_column :activities, :content_url, :string
    rename_column :activities, :content_url, :content_token
  end
end
