require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/badges'


describe BadgeProcessors::Processor do

  before(:each) do
    @app = create(:app)
    @member = create(:member, :app => @app)
    @badge = create(:newbish_badge, :app => @app, :badge_type => 'newbish', :qtty => 5)
     
    @act = create(:act, :app => @app, :actor_token => @member.member_token)
    @processor = BadgeProcessors::Newbish.new(@act, @badge)
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
  
  
end