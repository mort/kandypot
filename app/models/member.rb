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

  has_many :kandies, :through => :kandy_ownerships, :conditions => ['kandy_ownerships.status = ?', KandyOwnership::STATUSES.index(:active)] do
    

    def pick(amount, method = :rand)
      options = {:limit => amount}

      case method
        when :fifo
          find(:all, options.merge(:order => 'kandies.created_at ASC'))      
        when :lifo
          find(:all, options.merge(:order => 'kandies.created_at DESC'))      
        when :rand
          random(:all, options)
      end
    end

  end
  
  has_many :badge_grants
  has_many :badges, :through => :badge_grants
  
  validates_presence_of :member_token
  

  def receive_kandies(amount, activity_uuid)
    return false unless amount > 0
    amount.times { self.kandies.create }
  end
  
  def transfer_kandies(amount, recipient, activity_uuid)
    return false unless amount < self.kandies.count
    transfer_kandies = self.kandies.pick(amount, :fifo)
    
    transfer_kandies.each do |k|
      k.current_ownership.expire
      recipient.kandies << k
    end     
  end
    
  def update_kandy_cache
    kc = self.kandies.count
    self.update_attribute(:kandies_count, kc)
  end
  
  def has_badge?(badge)
    badges.collect(&:title).include?(badge.title)
  end

  def can_has_badge?(badge)
    return badge.repeatable? ? true : !has_badge?(badge)
  end

end
