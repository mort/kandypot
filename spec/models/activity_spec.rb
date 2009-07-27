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
    @app = App.make
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
  
end


 describe Activity, 'judgement' do
   before do
     @app = App.make
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
   
   
  it 'should reward content creation' do
    
    #mock(@m.app.settings.probabilities.default){0.7}
    #mock(@m.app.settings.amounts.deposits.creation).foo{33}

     #mock(Trickster).whim(10,0.5){10}

     mock.instance_of(Member).do_deposit(10,'creation')

     @a.judge
   end
   
   it 'should fall back to default amount for creation if amount for content type is not set' do
     @a2 = Activity.make(:member_token => @m.member_token, :app => @app, :content_type => 'wadus')
     
     #mock(@app.settings.probabilities).default {0.7}
     #mock(@app.settings.amounts.deposits.creation).default {10}

     #mock(Trickster).whim(10,0.7){10}

     mock.instance_of(Member).do_deposit(10,'creation')

     @a2.judge
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
   
   it 'should fall back to default amount if amount for reaction category is not set' do
    @m2 = Member.make(:app => @app)
    a2 = Activity.plan(:reaction, :category => 'foo', :app => @app, :member_token => @m.member_token, :member_b_token => @m2.member_token)
    @a2 = Activity.make(a2)
 
    #mock(@app.settings.probabilities).default{0.7}
    #mock(@app.settings.amounts.deposits.reaction).default{5}
    #mock(@app.settings.percentages.transfers.reaction).default{10}  

    #mock(Trickster).whim(5, 0.7){5}
    #mock(Trickster).whim(1, 0.7){1}

    mock.instance_of(Member).do_deposit(50,"reaction foo")
    mock.instance_of(Member).do_transfer(1, @m2, 'reaction foo (received)')

    @a2.judge
   end

    
end
 