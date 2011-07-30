require File.dirname(__FILE__) + '/../spec_helper'

describe OperationLog do
  
  
  it 'should know when its not executed' do
    op = build(:op)
    op.executed?.should be_false
  end
  
  it 'should be markable as executed' do
    op = build(:op)
    op.mark_as_executed
    op.executed?.should be_true
  end
  
  it 'should know when its executed' do
    op = build(:op)
    op.execute!
    op.executed?.should be_true
  end
   
  context 'executing a deposit operation log' do
  
    before(:each) do
      @op = create(:op)
    end
    
    it 'should execute the reward' do      
      @op.should_receive(:execute_reward)
      @op.should_not_receive(:execute_transfer)      
      
      @op.execute!
    end
    
    it 'should process the reward' do      
      @op = create(:op)

      m = mock_model(Member)
      a = mock_model(Array)
      app = mock_model(App)
  
      @op.should_receive(:app).and_return(app)
      app.should_receive(:members).and_return(a)
      a.should_receive(:find_or_create_by_member_token).with(@op.data[:actor_token]).and_return(m)
      m.should_receive(:receive_kandies).with(@op.data[:reward_amount],@op.data[:activity_uuid])
      
      @op.execute!
    end
    
  end
   
  context 'executing a deposit and transfer operation log' do
  
    before(:each) do
      
      h = Hash.new
      h[:actor_token] = Digest::MD5.hexdigest(Factory.next(:email))
      h[:transfer_recipient_token] = Digest::MD5.hexdigest(Factory.next(:email))
      h[:do_reward] = true
      h[:do_transfer] = true
      h[:reward_amount] = 10
      h[:transfer_amount] = 1
      
      @op = create(:transfer_op, :data => h)
    end
    
    
    it 'should execute the reward and the transfer' do      
      @op.should_receive(:execute_reward)    
      @op.should_receive(:execute_transfer)      
        
      @op.execute!
    end
    
    
    it 'should process the transfer' do      
    
       @op = create(:transfer_op)

       actor =  mock_model(Member)              
       recipient = mock_model(Member)       
       members = mock_model(Array)
       app = mock_model(App)

       @op.should_receive(:app).twice.and_return(app)
       app.should_receive(:members).twice.and_return(members)
       
       members.should_receive(:find_or_create_by_member_token).with(@op.data[:actor_token]).and_return(actor)
     members.should_receive(:find_or_create_by_member_token).with(@op.data[:transfer_recipient_token]).and_return(recipient)
  
       actor.should_receive(:transfer_kandies).with(@op.data[:transfer_amount], recipient, @op.data[:activity_uuid])

       @op.should_receive(:execute_reward)
       @op.execute!
    end
      
  
  
  end
   
  context 'executing a badgerified operation log' do
    before(:each) do
       
      b = create(:newbish_badge)
       
      h = Hash.new
      h[:do_badges] = true
      h[:badges] = {}
       
      h[:badges]["#{Digest::MD5.hexdigest(Factory.next(:email))}"] = {:badge_id => b.id, :badge_type => b.badge_type, :badge_title => b.title}
       
      @op = create(:op, :data => h, :app => b.app)
    end
          
    it 'should execute the reward' do      
      @op.should_receive(:execute_badges)      
      @op.execute!
    end
    
    it 'should process the badge' do
      app = mock_model(App)

      @op.should_receive(:app).and_return(app)
      app.should_receive(:members).and_return(members)
     
      member =  mock_model(Member)              
      members.should_receive(:find_or_create_by_member_token).with(@op.data[:badges]).and_return(member)
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

