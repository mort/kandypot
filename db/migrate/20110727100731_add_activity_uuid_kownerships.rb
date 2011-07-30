class AddActivityUuidKownerships < ActiveRecord::Migration
  def self.up
    add_column :kandy_ownerships, :activity_uuid, :string, :limit => 36, :null => false
  end

  def self.down
    remove_column :kandy_ownerships, :activity_uuid
  end
end
