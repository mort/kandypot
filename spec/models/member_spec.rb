require File.dirname(__FILE__) + '/../spec_helper'

describe Member, 'receiving kandies' do
  
  before do
    @amount = 50
    @subject = 'foo'
    @member = create(:member)
  end
    
  it 'should receive kandies' do
    lambda { 
     @member.receive_kandies(@amount, 'uuid')
    }.should change(@member.kandies, :count).by(@amount)
  end
  
  it 'should not create new kandies when amount is 0' do
    lambda { 
     @member.receive_kandies(0, @subject)
    }.should_not change(@member.kandies, :count)
  end
  
end


describe Member, 'transferring kandies' do
  
  before do
    @amount = 5
    @subject = 'foo'
    @sender = create(:member)
    @recipient = create(:member)
    
    @sender.receive_kandies(20,'foo')
  end
  
  it 'should decrease the sender kandies by amount' do
    
    lambda {
      @sender.transfer_kandies(@amount, @recipient, 'foo')
    }.should change(@sender.kandies, :count).by(@amount*-1)
  
  end
  
  it 'should increase the sender expired kandy ownerships by amount' do
   
    lambda {
      @sender.transfer_kandies(@amount, @recipient, 'foo')
    }.should change(@sender.kandy_ownerships.expired, :count).by(@amount)
  
  end

  it 'should increase the recipient kandies by amount' do
  
    lambda {
      @sender.transfer_kandies(@amount, @recipient, 'foo')
    }.should change(@recipient.kandies, :count).by(@amount)
 
  end

  it 'should not alter the number of kandies' do
 
    lambda {
      @sender.transfer_kandies(@amount, @recipient, 'foo')
    }.should_not change(Kandy, :count)
 
  end
  
end
  
  

describe Member, 'kandy cache' do

  
  it 'should be updatable per member' do
    @member = create(:member)
    amount = 50
    lambda{
      @member.receive_kandies(amount, 'foo')
      @member.update_kandy_cache
    }.should change(@member, :kandies_count).by(amount)
  end
    

end
# == Schema Information
#
# Table name: members
#
#  id                     :integer(4)      not null, primary key
#  app_id                 :integer(4)
#  member_token           :string(255)     default(""), not null
#  deposits_count         :integer(4)      default(0), not null
#  transfers_count        :integer(4)      default(0), not null
#  kandies_count          :integer(4)      default(0), not null
#  kandy_ownerships_count :integer(4)      default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#

