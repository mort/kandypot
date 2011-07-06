require File.dirname(__FILE__) + '/../../lib/hammurabi'
require File.dirname(__FILE__) + '/../spec_helper'

describe Trickster, 'modulate' do
  
  
  it 'should increase the probability for positive moods' do
    a = Trickster.modulate(:max => 0.9, :min => 0.1, :p => 0.5, :mood => 1)
    a.should be > 0.5
  end
  
  it 'should decrease the probability for negative moods' do
    a = Trickster.modulate(:max => 0.9, :min => 0.1, :p => 0.5, :mood => -1)
    a.should be < 0.5
  end
  
  it 'should increase the probability for unexpected moods' do
    a = Trickster.modulate(:max => 0.9, :min => 0.1, :p => 0.5, :mood => 99)
    a.should be > 0.5
  end
  
  it 'should return the max value if p goes over the max' do
    Math.stub!(:log10).and_return(10)
    a = Trickster.modulate(:max => 0.9, :min => 0.1, :p => 0.5, :intensity => 5, :mood => 1)
    a.should == 0.9
  end
  
  it 'should return the min value if p goes below the min' do
    Math.stub!(:log10).and_return(10)
    a = Trickster.modulate(:max => 0.9, :min => 0.1, :p => 0.5, :intensity => 5, :mood => -1)
    a.should == 0.1
  end


end

