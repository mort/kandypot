class Badge < ActiveRecord::Base
  serialize :params, Hash
  
  belongs_to :app
  
  has_many :badge_grants
  has_many :members, :through => :badge_grants
  
  BADGE_TYPES = ['Welcome', 'Newbish', 'Cycle', 'Spree', 'Diversity']
  
  BADGE_SPREE_TIME_PERIODS = ['year', 'month', 'day', 'hour']
  
  validates_inclusion_of :badge_type, :in => BADGE_TYPES
  validates_presence_of :title, :description, :params

end
