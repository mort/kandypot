# == Schema Information
# Schema version: 20090620104642
#
# Table name: operation_logs
#
#  id             :integer(4)      not null, primary key
#  member_id      :integer(4)
#  sender_id      :integer(4)
#  operation_type :string(255)     default(""), not null
#  amount         :integer(4)      default(0), not null
#  subject        :string(255)     default(""), not null
#  created_at     :datetime
#  updated_at     :datetime
#

class OperationLog < ActiveRecord::Base
  belongs_to :member
  belongs_to :sender, :class_name => 'Member'
end
