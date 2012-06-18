class Badge < ActiveRecord::Base
  belongs_to :app

  has_many :badge_grants
  has_many :members, :through => :badge_grants

  validates_presence_of :title, :description, :verb, :badge_type, :variant, :qtty, :badge_scope, :predicate_types

  validates_inclusion_of :repeatable, :in => [true, false]

  validates_presence_of :period_type, :if => Proc.new {|b| b.badge_type?(:cycle) || b.badge_type?(:streak)}

  named_scope :on, :conditions => {:status => 1}
  named_scope :off, :conditions => {:status => 0}
  
  serialize :params
  
  PARAMS_FIELDS = %w(qtty period_qtty verb predicate_types period_type period_variant max_level)
  
  PARAMS_FIELDS.each do |param_field|
    define_method(param_field) { 
     (params.present? && params[param_field]) ? params[param_field] : read_attribute(param_field.to_sym)
    }
    
  end
  

  def validate

    if (badge_type?(:diversity?) && ((predicate_types.size < 2) || predicate_type == '*') )
      errors.add(:predicate_types, 'Need more than one predicate type for diversity type, and it can\'t be a wildcard')
    end

    if (badge_type?(:diversity?) && repeatable)
      errors.add(:repeatable, 'Diversity badges cant be repeatable')
    end

  end

  def turn_on
    update_attribute(:status, 1)
  end

  def turn_off
    update_attribute(:status, 0)
  end


  def badge_type?(t)
    badge_type == t.to_s
  end

  def predicate_types
    read_attribute(:predicate_types).split(',')
  end

  def predicate_type
    predicate_types.first
  end

  def process(activity)
    processor.new(activity, self).process
  end

  def grant(member, activity, level = nil)
    logger.debug('Granting ')
    return false unless member.can_has_badge?(self)
    activity.op_data ||= {}
    activity.op_data[:do_badges] = true

    activity.op_data[:badges] ||= {}
    
    b = {
      :title => title,
      :description => description,
      :id => id,
      :variant => variant,
      :type => badge_type,
      :grant_activity_date => activity.published.to_s
    }
    
    b[:level] = level if level
    
    activity.op_data[:badges][member.member_token] = b
    
    activity.op_data[:badges][member.member_token]
  end

  private

  def processor
    name = "BadgeProcessors::#{badge_type.capitalize}"
    name.constantize
  end


end



# == Schema Information
#
# Table name: badges
#
#  id              :integer(4)      not null, primary key
#  app_id          :integer(4)
#  badge_type      :string(255)
#  title           :string(255)
#  description     :string(255)
#  params          :text
#  status          :integer(1)
#  created_at      :datetime
#  updated_at      :datetime
#  category        :string(255)
#  verb            :string(255)
#  predicate_types :string(255)
#  qtty            :integer(4)
#  variant         :string(1)
#  period_type     :string(2)
#  period_variant  :string(2)
#  badge_scope     :integer(2)
#  repeatable      :boolean(1)      default(FALSE), not null
#  p               :float           default(1.0), not null
#

