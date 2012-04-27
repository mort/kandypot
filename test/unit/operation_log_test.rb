require 'test_helper'

class OperationLogTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end






# == Schema Information
#
# Table name: operation_logs
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  activity_id :integer(4)
#  app_id      :integer(4)
#  data        :text
#  executed_at :datetime
#
# Indexes
#
#  index_operation_logs_on_app_id  (app_id)
#

