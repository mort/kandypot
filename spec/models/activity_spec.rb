require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before do
    @app = App.make
  end
  
  
  it 'should be queued for judgement' do
    lambda {
      a = Activity.make
    }.should change(Delayed::Job,:count).by(1)
  end
  
end


describe Activity, 'validation' do
  before do
    @app = App.make(:name => 'iwanna')
  end
  
  it 'should create well formed activities (creation)' do
    a = Activity.plan(:app => @app)
    
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should create well formed activities (reaction_*)' do
    a = Activity.plan(:reaction, :app => @app)
        
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should not create activities with unregistered reaction types' do
    a = Activity.plan(:reaction, :activity_type => 'reaction_foo', :app => @app) 
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  it 'should not create activities of type reaction if member_b_token is not present' do
    a = Activity.plan(:reaction, :member_b_token => '', :app => @app)
    activity = Activity.new(a)
    activity.should_not be_valid
  end

  it 'should not create activities of type relationship if member_b_token is not present' do
    a = Activity.plan(:relationship, :member_b_token => '', :app => @app)
    activity = Activity.new(a)
    activity.should_not be_valid
  end

  it 'should not create activities of type creation with a content_type not included in the app settings' do
    a = Activity.plan(:creation, :content_type => 'wadus', :app => @app)
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  it 'should not create activities of type reaction with a content_type not included in the app settings' do
    a = Activity.plan(:reaction, :content_type => 'comment', :app => @app)
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  it 'should not create activities of type reaction with a category not included in the app settings' do
    a = Activity.plan(:reaction, :category => 'wadus', :app => @app)
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  
end


 describe Activity, 'judgement' do
   before do
     @app = App.make(:name => 'iwanna')
     @m = Member.make(:app => @app)
     @a = Activity.make(:app => @app, :member_token => @m.member_token)
   end
   
   it 'should include the Hammurabi module' do
     @a.should respond_to(:judge)
   end
   
   it 'should have a judge creation method' do
     @a.should respond_to(:judge_creation)
   end
   
   it 'should have a judge_reaction method' do
     @a.should respond_to(:judge_reaction)
   end
   
   it 'should have a judge_relationship method' do
     @a.should respond_to(:judge_relationship)
   end
   
   
  it 'should reward content creation' do
    
    #mock(@m.app.settings.probabilities.default){0.7}
    #mock(@m.app.settings.amounts.deposits.creation).foo{33}

     #mock(Trickster).whim(10,0.5){10}

     mock.instance_of(Member).do_deposit(10,'creation')

     @a.judge
   end
   
   it 'should reward reaction' do
    @m2 = Member.make(:app => @app)
    @a2 = Activity.make(:reaction, :app => @app, :member_token => @m.member_token, :member_b_token => @m2.member_token)
  
    #mock(@app.settings.probabilities).default {0.7}
    #mock(@app.settings.amounts.deposits.reaction).comment{50}
    #mock(@app.settings.percentages.transfers.reaction).comment{10}  

    #mock(Trickster).whim(50, 0.7){50}
    #mock(Trickster).whim(5, 0.7){5}

    #mock.instance_of(Member).do_deposit(50,'reaction_comment')
    #mock.instance_of(Member).do_transfer(5, @m2, 'reaction_comment (received)')

    @a2.judge
   end    
   
   it 'should reward relationship' do
    @m2 = Member.make(:app => @app)
    @a2 = Activity.make(:relationship, :app => @app, :member_token => @m.member_token, :member_b_token => @m2.member_token)
  
    #mock(@app.settings.probabilities).default {0.7}
    #mock(@app.settings.amounts.deposits.reaction).comment{50}
    #mock(@app.settings.percentages.transfers.reaction).comment{10}  

    #mock(Trickster).whim(50, 0.7){50}
    #mock(Trickster).whim(5, 0.7){5}

    #mock.instance_of(Member).do_deposit(50,'reaction_comment')
    #mock.instance_of(Member).do_transfer(5, @m2, 'reaction_comment (received)')

    @a2.judge
   end
   
end


describe Activity, 'badges' do
  before do

    @app = App.make(:name => 'iwanna')    
    #stub(Activity).validate { true }
    stub.instance_of(Activity).validate_content_type {true}
    
    @m = Member.make(:app => @app)
  
  end
  
  it 'should concede a welcome badge' do
      # Badge de bienvenida al crear ese tipo de contenido
      params = { 'content_type' => 'default' }

      @badge = Badge.make(:app => @app, :title => 'Welcome Badge', :description => 'Welcome to the jungle!', :badge_type => 'Welcome', :params => params)
    
    @a = Activity.make(:app => @app, :member_token => @m.member_token, :content_type => 'default')
    @m.has_badge?(@badge.title).should be_true
  end
  
  it 'should concede a newbish badge after n' do
    n = 5
    params = { 'content_type' => 'default', 'n' => n }
    
     @badge = Badge.make(:app => @app, :title => 'Newbish Badge', :description => 'You are doing great', :badge_type => 'Newbish', :params => params)
    
    n.times { Activity.make(:app => @app, :member_token => @m.member_token, :content_type => 'default') }
    @m.has_badge?(@badge.title).should be_true
  end
  
  it 'should concede a diversity badge' do

    n = 2
    types = %w(item guide place)
    params = { 'content_types' => types.join(';'), 'n' => n }
    
     @badge = Badge.make(:app => @app, :title => 'Diversity Badge', :description => 'You have created three different types of content', :badge_type => 'Diversity', :params => params)
    
    types.each do |type| 
      n.times { Activity.make(:app => @app, :member_token => @m.member_token, :content_type => type) }
    end
    
    @m.has_badge?(@badge.title).should be_true
  end
  
  
  it 'should concede a spree badge' do

    n = 2
    period_qtty = 3
    period_type = 'day'
    content_type = '*'
    
    params = { 'n' => n, 
               'period_qtty' => period_qtty, 
               'period_type' => period_type, 
               'content_type' => content_type, 
              }
              
    
     @badge = Badge.make(:app => @app, :title => 'Spree Badge', :description => "You have created #{n} pieces of  content in #{period_qtty} consecutive #{period_type}s", :badge_type => 'Spree', :params => params)
    
    10.downto(0) do |i|
      n.times do
         Activity.make(:app => @app, :member_token => @m.member_token, :content_type => 'default', :activity_at => i.days.ago) 
        end
    end
        
    @m.has_badge?(@badge.title).should be_true
  end
  
  
end
 
