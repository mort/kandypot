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
# == Schema Information
#
# Table name: kandy_ownerships
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  kandy_id   :integer(4)
#  status     :integer(1)      default(1), not null
#  expired_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

