class AddMoodIntensityToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :mood, :string, :limit => 100
    add_column :activities, :intensity, :integer, :limit => 2
  end

  def self.down
    remove_column :activities, :mood
    remove_column :activities, :intensity
  end
end
