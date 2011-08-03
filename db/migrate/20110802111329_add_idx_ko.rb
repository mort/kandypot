class AddIdxKo < ActiveRecord::Migration
  def self.up
    # idx_on_kandy_id_status(kandy_id, status)
    add_index :kandy_ownerships, [:kandy_id, :status]
  end

  def self.down
    remove_index :kandy_ownerships, [:kandy_id, :status]
  end
end
