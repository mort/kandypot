require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/badges', __FILE__)

describe BadgeProcessors::BaseProcessor do

  before(:each) do
    @app = create(:app)
    @member = create(:member, :app => @app)
    @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5)

    @act = create(:act, :app => @app, :actor_token => @member.member_token)
    @processor = BadgeProcessors::Processor.new(@act, @badge)
  end

  it 'should not concede with a failed coin toss' do
    Trickster.should_receive(:coin_toss).with(@badge.p).and_return(false)

    @processor.concede?(2,2,@badge).should be_false
  end

  it 'should concede with a good coin toss' do
    @processor.should_receive(:right_count?).and_return(true)
    Trickster.should_receive(:coin_toss).with(@badge.p).and_return(true)

    @processor.concede?(2,2,@badge).should be_true
  end

  it 'should guess right counts when the badge is not repeatable' do
    badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :repeatable => false)
    @processor.concede?(badge.qtty,badge.qtty,badge).should be_true
  end

  it 'should guess bad counts when the badge is not repeatable' do
    badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :repeatable => false)
    @processor.concede?(badge.qtty*badge.qtty,badge.qtty,badge).should be_false
  end

  it 'should guess right counts when the badge is repeatable' do
    badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :repeatable => true)
    badge.should_receive(:max_level).and_return(5)
    @processor.concede?(badge.qtty*badge.qtty,badge.qtty,badge).should be_true
  end

  it 'should guess bad counts by defect when the badge is repeatable' do
    badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :repeatable => true)
    @processor.concede?((badge.qtty*badge.qtty)-1,badge.qtty,badge).should be_false
  end

  it 'should guess bad counts by excess when the badge is repeatable' do
    badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :repeatable => true)
    @processor.concede?((badge.qtty*badge.qtty)+1,badge.qtty,badge).should be_false
  end


end
