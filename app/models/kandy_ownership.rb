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
  
  STATUSES = [:active, :expired]
  
  STATUSES.each_with_index do |status, i|
    options = {:conditions => {:status => i}} 
    self.send(:named_scope, status, options)
    
    n = "#{status}?"
    
    define_method(n.to_sym) { 
      (self.status == i) 
    }
        
  end
  
  
  def expire
    self.update_attributes(:status => STATUSES.index(:expired), :expired_at => Time.now)
  end
  
end
