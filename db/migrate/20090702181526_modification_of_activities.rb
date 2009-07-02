class ModificationOfActivities < ActiveRecord::Migration
  def self.up
    rename_column :activities, :credentials_app_token, :app_token
    rename_column :activities, :credentials_signature, :signature
    rename_column :activities, :content_owner_member_token, :member_b_token

    add_column :activities, :category, :string

  end

  def self.down
  end
end
