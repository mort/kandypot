class BadgeGrant < ActiveRecord::Base
  belongs_to :badge
  belongs_to :member
end
