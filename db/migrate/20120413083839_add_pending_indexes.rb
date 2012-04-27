class AddPendingIndexes < ActiveRecord::Migration
  def self.up
    add_index :members, [:app_id, :kandies_count], :name => 'members_app_id_kandies_count'
    add_index :notifications, :app_id
    add_index :members, [:member_token, :app_id], :name => 'members_member_token_app_id'
    add_index :operation_logs, :app_id
  end

  def self.down
    remove_index :members, :name => 'members_app_id_kandies_count'
    remove_index :notifications, :app_id
    remove_index :members, :name => 'members_member_token_app_id'
    remove_index :operation_logs, :app_id
  end
end
