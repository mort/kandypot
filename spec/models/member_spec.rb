require File.dirname(__FILE__) + '/../spec_helper'

describe Member, 'doing a deposit' do
  
  before do
    @amount = 50
    @subject = 'foo'
    @member = Member.make
  end
    
  it 'should create <ammount> new kandies' do
    lambda { 
     @member.do_deposit(@amount, @subject)
    }.should change(@member.kandies, :count).by(@amount)
  end
  
  it 'should create a log of the deposit' do
    lambda { 
     @member.do_deposit(@amount, @subject)
    }.should change(@member.deposits, :count).by(1)
  end
  
  it 'should not create new kandies if amount is 0' do
    lambda { 
     @member.do_deposit(0, @subject)
    }.should_not change(@member.kandies, :count)
  end

  it 'should not create a log of the deposit if amount is 0' do
    lambda { 
     @member.do_deposit(0, @subject)
    }.should_not change(@member.deposits, :count)
  end
  
  
end


describe Member, 'doing a transfer' do
  
  before do
    @amount = 5
    @subject = 'foo'
    @sender = Member.make
    @recipient = Member.make
    
    @sender.do_deposit(20,'foo')
  end
  
  it 'should decrease the sender kandies by amount' do
    lambda {
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should change(@sender.kandies, :count).by(@amount*-1)
  end
  
  it 'should increase the sender expired kandy ownerships by amount' do
    lambda {
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should change(@sender.kandy_ownerships.expired, :count).by(@amount)
  end

  it 'should increase the recipient kandies by amount' do
    lambda {
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should change(@recipient.kandies, :count).by(@amount)
  end

  it 'should not alter the number of kandies' do
    lambda {
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should_not change(Kandy, :count)
  end
  
  it 'should create a log of the transfer for the recipient' do
    lambda { 
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should change(@recipient.transfers, :count).by(1)
  end
  
  it 'should create a log of the transfer for the sender' do
    lambda { 
      @sender.do_transfer(@amount, @recipient, 'foo')
    }.should change(@sender.sent_transfers, :count).by(1)
  end
  
  
end  

describe Member, 'kandy cache' do
  before do
    @member = Member.make
  end
  
  it 'should be updatable per member' do
    lambda{
      @member.do_deposit(50, 'foo')
      @member.update_kandy_cache
    }.should change(@member, :kandies_count).by(50)
  end
    

end