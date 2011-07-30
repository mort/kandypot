# == Schema Information
# Schema version: 20090619222107
#
# Table name: kandy_ownerships
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  kandy_id   :integer(4)
#  status     :integer(1)      default(1), not null
#  expired_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class KandyOwnership < ActiveRecord::Base
  belongs_to :kandy
  belongs_to :member
  
  STATUSES = {:expired => 0, :active => 1}
  
  STATUSES.each do |k,v|
    self.send(:named_scope, k, {
      :conditions => {:status => v}
      })
        
    define_method("#{k.to_s}?") { 
      (self.status == v) 
    }
        
  end
  
  before_create :expire_current
    
  def expire
    self.update_attributes(:status => STATUSES[:expired], :expired_at => Time.now)
  end
  
  private
  
  def expire_current
    kandy.current_ownership.expire unless kandy.current_ownership.nil?
  end
  
end
