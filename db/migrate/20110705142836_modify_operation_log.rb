class ModifyOperationLog < ActiveRecord::Migration
  def self.up
    add_column :operation_logs, :activity_id, :integer
    add_column :operation_logs, :app_id, :integer
    add_column :operation_logs, :data, :text
    add_column :operation_logs, :executed_at, :datetime, :default => nil

    remove_column :operation_logs, :member_id
    remove_column :operation_logs, :sender_id
    remove_column :operation_logs, :operation_type
    remove_column :operation_logs, :amount
    remove_column :operation_logs, :subject
  end

  def self.down
  end
end
