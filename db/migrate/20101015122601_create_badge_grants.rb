class CreateBadgeGrants < ActiveRecord::Migration
  def self.up
    create_table :badge_grants do |t|
      t.references(:badge)
      t.references(:member)
      t.timestamps
    end
  end

  def self.down
    drop_table :badge_grants
  end
end
