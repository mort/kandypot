class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.references(:app)
      t.string :badge_type
      t.string :title
      t.string :description
      t.text :params
      t.integer :status, :limit => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :badges
  end
end
