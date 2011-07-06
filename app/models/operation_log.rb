class OperationLog < ActiveRecord::Base
  belongs_to :app
  belongs_to :activity
  
  validates_presence_of :data
  
  serialize :data
  
  def executed?
    !executed_at.nil?
  end
  
  def execute!
    begin
      execute_reward if data[:do_reward]
      execute_transfer if data[:do_transfer]
      mark_as_executed
    end
  end
  
  def mark_as_executed
    update_attribute(:executed_at, Time.now)
  end
  
  private
  
  def execute_reward
    return unless data[:do_reward]
    
    actor_token = data[:actor_token]
    uuid = data[:activity_uuid]
    
    actor = app.members.find_or_create_by_member_token(actor_token)
    actor.receive_kandies(data[:reward_amount], uuid)
  
  end
  
  def execute_transfer
    return unless data[:do_transfer]
        
    actor_token = data[:actor_token]
    recipient_token = data[:transfer_recipient_token]
    reward_amount = data[:reward_amount]
    uuid = data[:activity_uuid]
    
    actor = app.members.find_or_create_by_member_token(actor_token)
    recipient = app.members.find_or_create_by_member_token(recipient_token)

    actor.transfer_kandies(reward_amount, recipient, uuid)

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

