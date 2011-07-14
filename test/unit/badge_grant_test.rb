require 'test_helper'

class BadgeGrantTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: badge_grants
#
#  id         :integer(4)      not null, primary key
#  badge_id   :integer(4)
#  member_id  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

