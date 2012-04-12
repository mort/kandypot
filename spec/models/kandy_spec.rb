require File.expand_path('../../spec_helper', __FILE__)

describe Kandy do
  before(:each) do
    @kandy = Kandy.make
  end

  it 'should have an uuid' do
    @kandy.uuid.should_not be_blank
  end

end
# == Schema Information
#
# Table name: kandies
#
#  id         :integer(4)      not null, primary key
#  uuid       :string(36)      not null
#  created_at :datetime
#  updated_at :datetime
#

