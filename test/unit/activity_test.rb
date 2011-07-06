require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                  :integer(4)      not null, primary key
#  app_id              :integer(4)
#  processed_at        :datetime
#  proccessing_status  :integer(2)
#  ip                  :string(15)      not null
#  category            :string(25)      not null
#  uuid                :string(36)      not null
#  published           :datetime        not null
#  actor_token         :string(32)      not null
#  verb                :string(255)     not null
#  object_type         :string(255)
#  object_url          :string(255)
#  target_type         :string(255)
#  target_token        :string(32)
#  target_url          :string(255)
#  target_author_token :string(32)
#  mood                :string(25)
#  intensity           :integer(2)
#  created_at          :datetime
#  updated_at          :datetime
#

