class OperationLog < ActiveRecord::Base
  belongs_to :app
  belongs_to :activity
  
  validates_presence_of :data
  
  serialize :data
  
  after_create do |op|
    op.send_later :execute!
  end
  
  def executed?
    !executed_at.nil?
  end
  
  def execute!(force = false)
    return if (executed? && !force)

    begin
      
      # Process each of the callbacks
      %w(reward transfer badges).each do |s|
        send("execute_#{s}") if data["do_#{s}".to_sym]
      end

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
    
    actor = app.members.find_or_create_by_member_token(actor_token)
    actor.receive_kandies(data[:reward_amount], activity.uuid)
  
  end
  
  def execute_transfer
    return unless data[:do_transfer]
        
    actor_token = data[:actor_token]
    recipient_token = data[:transfer_recipient_token]
    transfer_amount = data[:transfer_amount]
        
    actor = app.members.find_or_create_by_member_token(actor_token)
    recipient = app.members.find_or_create_by_member_token(recipient_token)
    
    actor.transfer_kandies(transfer_amount, recipient, activity.uuid) 

  end
  
  def execute_badges
    return unless data[:do_badges]
         
    data[:badges].each do |member_token,b|
      member = app.members.find_or_create_by_member_token(member_token)
      badge = app.badges.find(b[:badge_id])
      member.receive_badge(badge, activity.uuid) 
    end 
     
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

