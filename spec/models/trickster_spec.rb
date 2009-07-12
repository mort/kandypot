require File.dirname(__FILE__) + '/../spec_helper'

describe Trickster, 'modulate' do
  
  before do
    @max = 0.9
    @min = 0.1
    @p = 0.5
  end
  
  it 'should increase the probability for positive moods' do
    a = Trickster.modulate(@p, 'positive', 5, @max, @min)
    a.should be > @p
  end
  
  it 'should decrease the probability for negative moods' do
    a = Trickster.modulate(@p, 'negative', 5, @max, @min)
    a.should be < @p
  end
  
  it 'should increase the probability for unknown moods' do
    a = Trickster.modulate(@p, 'foo', 5, @max, @min)
    a.should be > @p
  end
  
  it 'should return the max value if p goes over the max' do
    mock(Math).log10(5){100}
    a = Trickster.modulate(@p, 'positive', 5, @max, @min)
    a.should == @max
  end
  
  it 'should return the min value if p goes below the min' do
    mock(Math).log10(5){100}
    a = Trickster.modulate(@p, 'negative', 5, @max, @min)
    a.should == @min
  end


end

