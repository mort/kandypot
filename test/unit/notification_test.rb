require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end


# == Schema Information
#
# Table name: notifications
#
#  id         :integer(4)      not null, primary key
#  app_id     :integer(4)
#  title      :string(255)     default(""), not null
#  body       :text            default(""), not null
#  category   :string(255)     default(""), not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_notifications_on_app_id  (app_id)
#

