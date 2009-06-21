# == Schema Information
# Schema version: 20090620163846
#
# Table name: kandies
#
#  id         :integer(4)      not null, primary key
#  uuid       :string(36)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
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
