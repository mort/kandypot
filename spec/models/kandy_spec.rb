require File.dirname(__FILE__) + '/../spec_helper'

describe Kandy do
  before(:each) do
    @kandy = Kandy.make
  end
  
  it 'should have an uuid' do
    @kandy.uuid.should_not be_blank
  end

end