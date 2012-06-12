require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/badges', __FILE__)

describe BadgeProcessors::Diversity do

  context 'with member scope' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:diversity_badge, :app => @app, :predicate_types => 'foo,bar,wadus')
      @act = create(:creation_act, :app => @app, :actor_token => @member.member_token, :object_type => 'foo')
      @processor = BadgeProcessors::Diversity.new(@act, @badge)
    end

    it 'should be granted when activity reaches the threshold and other types are on the threshold' do
      Activity.should_receive(:count).with(anything()).exactly(3).and_return(@badge.qtty)

      @processor.process
      @processor.concede.should be_true
    end

    it 'should not be granted when activity is under the threshold' do
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty-1)
      @processor.process
      @processor.concede.should be_false
    end

    it 'should not be granted when activity reaches the threshold but other types are under the threshold' do
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty)
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty-1)

      @processor.process
      @processor.concede.should be_false
    end

    it 'should not be granted when activity reaches the threshold and some other types are over the threshold but others under it' do
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty)
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty+1)
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty-1)

      @processor.process
      @processor.concede.should be_false
    end

    it 'should be granted when activity reaches the threshold and other types are over the threshold' do
      Activity.should_receive(:count).with(anything()).once.and_return(@badge.qtty)
      Activity.should_receive(:count).with(anything()).twice.and_return(@badge.qtty+1)

      @processor.process
      @processor.concede.should be_true
    end



  end

end
