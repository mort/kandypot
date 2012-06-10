require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/badges', __FILE__)

describe BadgeProcessors::Newbish do

  context 'with member scope, non repeatable' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5)

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end


    it 'should not grant the badge when the count is less than the expected' do
      c = @badge.qtty-1
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(false)
      Member.should_not_receive(:find_by_member_token).with(@act.actor_token)
      @member.should_not_receive(:grant)
      @processor.process
      @processor.concede.should be_false
    end

    it 'should not grant the badge when the count is more than the expected' do
      c = @badge.qtty+1
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(false)
      Member.should_not_receive(:find_by_member_token).with(@act.actor_token)
      @badge.should_not_receive(:grant)

      @processor.process
      @processor.concede.should be_false
    end

    it 'should grant the badge when the count is the expected' do
      c = @badge.qtty
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(true)
      Member.should_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_receive(:grant).with(@member, @act, nil)

      @processor.process
      @processor.concede.should be_true
    end

    it 'should have been initialized correctly' do
      @processor.badge.should == @badge
      @processor.activity.should == @act
      @processor.concede.should be_false
    end

    it 'should have the right conditions str' do
      @processor.process
      @processor.cond_str.include?("activities.app_id = ?").should be_true
      @processor.cond_str.include?('activities.actor_token = ?').should be_true
      @processor.cond_str.include?('activities.verb = ?').should be_true

    end

    it 'should have the right conditions params' do
      @processor.process
      @processor.cond_params.include?(@app.id).should be_true
      @processor.cond_params.include?(@member.member_token).should be_true
      @processor.cond_params.include?(@badge.verb).should be_true
    end


  end



  context 'with global scope' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :badge_scope => BadgeScope.find_by_name('global').id)

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end

    it 'should have the right conditions str' do
      @processor.process
      @processor.cond_str.include?("activities.app_id = ?").should be_false
      @processor.cond_str.include?('activities.actor_token = ?').should be_false
    end

    it 'should have the right conditions params' do
      @processor.process
      @processor.cond_params.include?(@app.id).should be_false
      @processor.cond_params.include?(@member.member_token).should be_false
    end

  end

  context 'with member scope, repeatable' do
    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :repeatable => true, :app => @app, :badge_type => 'newbish', :qtty => 5, :params => {:max_level => 100})

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end

    it 'should grant the badge when the count is the expected' do
      c = @badge.qtty
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:level_check).with(c,@badge.qtty,@badge).and_return((@processor.level_calc(c,@badge.qtty) <= @badge.max_level))
      @processor.should_receive(:level_calc).with(c,@badge.qtty).and_return((c/@badge.qtty))
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(true)
      Member.should_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_receive(:grant).with(@member, @act, (c/@badge.qtty))

      @processor.process
      @processor.concede.should be_true
    end

    it 'should grant the badge when the count is a multiple of the expected' do
      c = @badge.qtty*@badge.qtty
      Activity.should_receive(:count).with(anything()).and_return(c)

      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(true)
      Member.should_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_receive(:grant).with(@member, @act,(c/@badge.qtty))

      @processor.process
      @processor.concede.should be_true
    end
    
    
    it 'should have the right level when the count is a multiple of the expected' do
      c = @badge.qtty*@badge.qtty
      Activity.should_receive(:count).with(anything()).and_return(c)

      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(true)
      @processor.should_receive(:level_check).with(c, @badge.qtty, @badge).and_return((c / @badge.qtty))
      Member.should_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_receive(:grant).with(@member, @act, (c / @badge.qtty))

      @processor.process
      assert_equal @processor.level, (c / @badge.qtty)
      @processor.concede.should be_true
    end
    

    it 'should not grant the badge when the count is over a multiple of the expected' do
      c = (@badge.qtty*@badge.qtty)+1
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(false)
      Member.should_not_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_not_receive(:grant).with(@member, @act)

      @processor.process
      @processor.concede.should be_false
    end

    it 'should not grant the badge when the count is under multiple of the expected' do
      c = (@badge.qtty*@badge.qtty)-1
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(false)
      Member.should_not_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_not_receive(:grant).with(@member, @act)

      @processor.process
      @processor.concede.should be_false
    end

    it 'should not grant the badge when the level exceeds max level' do
      c = (@badge.qtty*@badge.qtty)-1
      Activity.should_receive(:count).with(anything()).and_return(c)
      @processor.should_receive(:right_count?).with(c, @badge.qtty, @badge).and_return(true)
      @badge.should_receive(:max_level).and_return((c/@badge.qtty)-1)
      Member.should_not_receive(:find_by_member_token).with(@act.actor_token).and_return(@member)
      @badge.should_not_receive(:grant).with(@member, @act)

      @processor.process
      @processor.concede.should be_false
    end



  end

  context 'with app scope' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :badge_scope => BadgeScope.find_by_name('app').id)

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end

    it 'should have the right conditions str' do
      @processor.process
      @processor.cond_str.include?("activities.app_id = ?").should be_true
      @processor.cond_str.include?('activities.actor_token = ?').should be_false
      @processor.cond_str.include?('activities.verb = ?').should be_true
    end

    it 'should have the right conditions params' do
      @processor.process
      @processor.cond_params.include?(@app.id).should be_true
      @processor.cond_params.include?(@member.member_token).should be_false
      @processor.cond_params.include?(@badge.verb).should be_true
    end

  end


  context 'with wildcard predicate types' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :predicate_types => '*')

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end

    it 'should have the right conditions str' do
      @processor.process
      @processor.cond_str.include?("activities.#{@act.predicate_attr.to_s} =").should be_false
    end

    it 'should have the right conditions params' do
      @processor.process
      @processor.cond_params.include?(@act.predicate_type).should be_false
    end

  end

  context 'with a wildcard verb' do

    before(:each) do
      @app = create(:app)
      @member = create(:member, :app => @app)
      @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5, :verb => '*')

      @act = create(:act, :app => @app, :actor_token => @member.member_token)
      @processor = BadgeProcessors::Newbish.new(@act, @badge)
    end

    it 'should have the right conditions str' do
      @processor.process
      @processor.cond_str.include?("activities.verb =").should be_false
    end

    it 'should have the right conditions params' do
      @processor.process
      assert @processor.cond_params.include?(@badge.verb).should be_false
    end

  end


end
