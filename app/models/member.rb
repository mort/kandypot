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

    amount.times { kandy_ownerships.create(:kandy => Kandy.create, :activity_uuid => activity_uuid) }

    increase_kandy_balance_by(amount)
  end

  def transfer_kandies(amount, recipient, activity_uuid)
    return false unless amount < kandies_count

    kandies.pick(amount, :fifo).each { |k| recipient.kandy_ownerships.create(:kandy_id => k.id, :activity_uuid => activity_uuid) }

    decrease_kandy_balance_by(amount)
    recipient.increase_kandy_balance_by(amount)

  end
  
  def increase_kandy_balance_by(amount)
    logger.debug("+ amount #{amount}")
    update_attribute(:kandies_count, kandies_count + amount)
  end
  
  def decrease_kandy_balance_by(amount)
    logger.debug("- amount #{amount}")
    update_attribute(:kandies_count, kandies_count - amount)
  end
  
  def update_kandy_balance
    update_attribute(:kandies_count, kandies.count)
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

