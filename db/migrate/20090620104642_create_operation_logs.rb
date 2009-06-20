class CreateOperationLogs < ActiveRecord::Migration
  def self.up
    create_table :operation_logs do |t|
      t.references :member
      t.references :sender
      t.string :operation_type, :null => false, :default => ''
      t.integer :amount, :null => false, :default => 0
      t.string :subject, :null => false, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :operation_logs
  end
end
