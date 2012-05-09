class Member < ActiveRecord::Base
  belongs_to :app

  has_many :kandy_ownerships

  has_many :kandies, :through => :kandy_ownerships, :conditions => ['kandy_ownerships.status = ?', KandyOwnership::STATUSES[:active]] do


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
    amount.times do
      k = Kandy.create
      kandy_ownerships.create(:kandy_id => k.id, :activity_uuid => activity_uuid)
    end
    add_to_kandies_cache(amount)
  end

  def transfer_kandies(amount, recipient, activity_uuid)
    return false unless amount < self.kandies.count

    self.kandies.pick(amount, :fifo).each { |k| recipient.kandy_ownerships.create(:kandy_id => k.id, :activity_uuid => activity_uuid) }
    substract_from_kandies_cache(amount)
    recipient.add_to_kandies_cache(amount)
  end
  
  def add_to_kandies_cache(amount)
    update_attribute(:kandies_count, kandies_count+amount)
  end
  
  def substract_from_kandies_cache(amount)
    update_attribute(:kandies_count, kandies_count-amount)
  end

  def receive_badge(badge, activity_uuid)
    badge_grants.create(:activity_uuid => activity_uuid, :badge_id => badge.id) if can_has_badge?(badge)
  end


  def has_badge?(badge)
    badges.collect(&:title).include?(badge.title)
  end

  def can_has_badge?(badge)
    return badge.repeatable? ? true : !has_badge?(badge)
  end

  def update_kandy_cache
    kc = self.kandies.count
    self.update_attribute(:kandies_count, kc)
  end


end


# == Schema Information
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
# Indexes
#
#  index_members_on_member_token  (member_token) UNIQUE
#  members_app_id_kandies_count   (app_id,kandies_count)
#  members_member_token_app_id    (member_token,app_id)
#

