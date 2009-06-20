# == Schema Information
# Schema version: 20090619222107
#
# Table name: kandies
#
#  id                 :integer(4)      not null, primary key
#  kandy_ownership_id :integer(4)
#  uuid               :string(36)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#

require 'uuid'

class Kandy < ActiveRecord::Base
  has_many :kandy_ownerships
  has_one :current_ownership, :class_name => 'KandyOwnership', :conditions => ['kandy_ownerships.status = ?', KandyOwnership::STATUSES.index(:active)]
  
  validates_presence_of :uuid

  before_validation do |k|
    k.uuid = UUID.new.generate
  end

end
