require 'test_helper'

class KandyOwnershipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
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

