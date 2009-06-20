# == Schema Information
# Schema version: 20090619222107
#
# Table name: members
#
#  id                     :integer(4)      not null, primary key
#  app_id                 :integer(4)
#  member_token           :string(255)     default(""), not null
#  deposits_count         :integer(4)      default(0), not null
#  transfers_count        :integer(4)      default(0), not null
#  kandies_count          :integer(4)      default(0), not null
#  kandy_ownerships_count :integer(4)      default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#

class Member < ActiveRecord::Base
  belongs_to :app
  
  has_many :kandy_ownerships
  has_many :kandies, :through => :kandy_ownerships, :conditions => ['kandy_ownerships.status = ?', KandyOwnership::STATUSES.index(:active)]

end
