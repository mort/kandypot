require File.dirname(__FILE__) + '/../spec_helper'

describe KandyOwnership do
  
  before(:each) do
    @kandy_ownership = KandyOwnership.make
  end
  
  it 'should be expirable' do
    @kandy_ownership.should respond_to(:expire) 
  end
  
  it 'should set the right status and expiration date at expiration' do
    @kandy_ownership.expire
    @kandy_ownership.status.should == KandyOwnership::STATUSES.index(:expired)
    @kandy_ownership.expired_at.should_not be_nil
  end
  
end