class BadgeGrant < ActiveRecord::Base
  belongs_to :badge
  belongs_to :member
end


# == Schema Information
#
# Table name: badge_grants
#
#  id            :integer(4)      not null, primary key
#  badge_id      :integer(4)
#  member_id     :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  activity_uuid :string(36)      not null
#

