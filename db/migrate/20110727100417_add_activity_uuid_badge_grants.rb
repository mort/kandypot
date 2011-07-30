class AddActivityUuidBadgeGrants < ActiveRecord::Migration
  def self.up
    add_column :badge_grants, :activity_uuid, :string, :limit => 36, :null => false
  end

  def self.down
    remove_column :badge_grants, :activity_uuid
  end
end
