require File.expand_path('../../spec_helper', __FILE__)

describe KandyOwnership do

  before(:each) do
    @ko = create(:kandy_ownership)
  end

  it 'should not be expired' do
    @ko.should_not be_expired
  end

  it 'should expire the prior ownership on creation' do
    @ko_two = create(:kandy_ownership, :kandy_id => @ko.kandy.id)

    KandyOwnership.find(@ko.id).should be_expired
  end

end

# == Schema Information
#
# Table name: kandy_ownerships
#
#  id            :integer(4)      not null, primary key
#  member_id     :integer(4)
#  kandy_id      :integer(4)
#  status        :integer(1)      default(1), not null
#  expired_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  activity_uuid :string(36)      not null
#

