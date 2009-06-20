class CreateKandies < ActiveRecord::Migration
  def self.up
    create_table :kandies do |t|
      t.references :kandy_ownership
      t.string :uuid, :limit => 36, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :kandies
  end
end
