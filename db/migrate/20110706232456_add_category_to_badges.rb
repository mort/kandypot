class AddCategoryToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :category, :string
  end

  def self.down
    remove_column :badges, :category
  end
end
