require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
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

