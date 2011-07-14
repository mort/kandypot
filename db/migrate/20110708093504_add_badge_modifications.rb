class AddBadgeModifications < ActiveRecord::Migration
  def self.up
    add_column :badges, :verb, :string
    add_column :badges, :predicate_types, :string
    add_column :badges, :qtty, :integer
    add_column :badges, :variant, :string, :limit => 1
    add_column :badges, :period_type, :string, :limit => 2
    add_column :badges, :period_variant, :string, :limit => 2
    add_column :badges, :badge_scope, :integer, :limit => 2
    add_column :badges, :repeatable, :boolean, :default => false, :null => false
    add_column :badges, :p, :float, :default => 1.0, :null => false
  end

  def self.down
    remove_column :badges, :verb
    remove_column :badges, :predicate_types
    remove_column :badges, :qtty
    remove_column :badges, :variant
    remove_column :badges, :period_type
    remove_column :badges, :period_variant
    remove_column :badges, :badge_scope
    remove_column :badges, :repeatable
    remove_column :badges, :p
  end
end
