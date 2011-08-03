class BiggerVariantFieldForBadges < ActiveRecord::Migration
  def self.up
    change_column :badges, :variant, :string
  end

  def self.down
    change_column :badges, :variant, :string, :length => 1
  end
end
