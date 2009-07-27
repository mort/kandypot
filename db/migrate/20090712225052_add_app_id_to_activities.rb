class AddAppIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :app_id, :integer, :null => false
  end

  def self.down
    remove_column :activities, :app_id
  end
end
