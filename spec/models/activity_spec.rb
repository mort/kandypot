require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before do
    @app = App.make
  end
  
  
  it 'should be queued for judgement' do
    lambda {
      a = Activity.plan
      s = sign_n_make(a, @app)
    }.should change(Delayed::Job,:count).by(1)
  end
  
end


describe Activity, 'validation' do
  before do
    @app = App.make
  end
  
  it 'should create well formed activities (creation)' do
   a = Activity.plan(:app_token => @app.app_token)
    
    params = {}
    params["member_token"]   = a[:member_token]
    params["activity_type"]  = a[:activity_type]
    params["activity_at"]    = a[:activity_at]

    s = Digest::SHA1.hexdigest(params.to_s)   

   a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)

    mock(App).pack_up_params_for_signature(params){ s }
    mock(App).authenticate(a[:app_token], s, a[:signature]){true}
    
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should create well formed activities (reaction_*)' do
    a = Activity.plan(:reaction, :app_token => @app.app_token)
    
    
      params = {}
      params["member_token"]   = a[:member_token]
      params["activity_type"]  = a[:activity_type]
      params["activity_at"]    = a[:activity_at]


      s = Digest::SHA1.hexdigest(params.to_s)   

     a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)

      mock(App).pack_up_params_for_signature(params){ s }
      mock(App).authenticate(a[:app_token], s, a[:signature]){true}
    
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should not create activities with unregistered reaction types' do
    a = Activity.plan(:reaction, :activity_type => 'reaction_foo', :app_token => @app.app_token) 
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  it 'should not create activities of type reaction if member_b_token is not present' do
    a = Activity.plan(:reaction, :member_b_token => '', :app_token => @app.app_token)
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
end

describe Activity, 'authentication' do
  
  before do
    @app = App.make
    @a = Activity.plan(:app_token => @app.app_token)
  end
  
  it 'should authenticate well signed activities' do
    
    # SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
    params = {}
    params["member_token"]   = @a[:member_token]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]

    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
  
    mock(App).pack_up_params_for_signature(params){ s }
    mock(App).authenticate(@a[:app_token], s, @a[:signature]){true}
  
    a = Activity.new(@a)
    a.authenticated?.should be_true
  end
  
  it 'should not authenticate badly signed activities (bad app key)' do

     params = {}
     # SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
     params["member_token"]   = @a[:member_token]
     params["activity_type"]  = @a[:activity_type]
     params["activity_at"]    = @a[:activity_at]


     s = Digest::SHA1.hexdigest(params.to_s)   
     
     @a[:app_token] = @app.app_token
     @a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, 'foo', s)

     mock(App).pack_up_params_for_signature(params){ s }
     mock(App).authenticate(@a[:app_token], s, @a[:signature]){false}
     
     # App.authenticate(self.app_token, packed_signature_params, self.signature)
     a = Activity.new(@a)
     a.authenticated?.should be_false
  end
  
  it 'should not authenticate badly signed activities (bad params string)' do

     params = {}
     params["member_token"]   = @a[:member_token]
     params["activity_type"]  = @a[:activity_type]
     params["activity_at"]    = @a[:activity_at]

     s = Digest::SHA1.hexdigest(params.to_s)   
     
     @a[:app_token] = @app.app_token
     @a[:signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, 'foo')

     mock(App).pack_up_params_for_signature(params){ s }
     mock(App).authenticate(@a[:app_token], s, @a[:signature]){false}
     
     # App.authenticate(self.app_token, packed_signature_params, self.signature)
     a = Activity.new(@a)
     a.authenticated?.should be_false
  end
  
 
end



 describe Activity, 'judgement' do
   before do
     @app = App.make
     @m = Member.make(:app => @app)
     a = Activity.plan(:app_token => @app.app_token, :member_token => @m.member_token)
     @a = sign_n_make(a,@app)     
   end
   
   it 'should include the Hammurabi module' do
     @a.should respond_to(:judge)
   end
   
   it 'should have a judge creation method' do
     @a.should respond_to("judge_creation".to_sym)
   end
   
   it 'should have a judge_reaction method' do
     #a = Activity.plan(:reaction, :app_token => @app.app_token, :member_token => @m.member_token)
    # @a = sign_n_make(a,@app)
     @a.should respond_to('judge_reaction')
   end
   
   
   it 'should reward content creation' do
     mock(App).find_by_app_token(@a.app_token){@app} 

     mock(@app.settings.probabilities).default {0.7}
     mock(@app.settings.amounts.deposits.creation).foo {10}

     mock(Trickster).whim(10,0.7){10}

     mock.instance_of(Member).do_deposit(10,'creation')

     @a.judge
   end
   
   it 'should fall back to default amount for creation if amount for content type is not set' do
     a2 = Activity.plan(:app_token => @app.app_token, :member_token => @m.member_token, :content_type => 'wadus')
     @a2 = sign_n_make(a2,@app)     
     
     mock(App).find_by_app_token(@a2.app_token){@app} 

     mock(@app.settings.probabilities).default {0.7}
     mock(@app.settings.amounts.deposits.creation).default {10}

     mock(Trickster).whim(10,0.7){10}

     mock.instance_of(Member).do_deposit(10,'creation')

     @a2.judge
   end
   

   it 'should reward reaction' do
    @m2 = Member.make(:app => @app)
    a2 = Activity.plan(:reaction, :app_token => @app.app_token, :member_token => @m.member_token, :member_b_token => @m2.member_token)
    @a2 = sign_n_make(a2,@app) 
 
    mock(App).find_by_app_token(@a2.app_token){@app} 

    mock(@app.settings.probabilities).default {0.7}
    mock(@app.settings.amounts.deposits.reaction).comment{50}
    mock(@app.settings.percentages.transfers.reaction).comment{10}  

    mock(Trickster).whim(50, 0.7){50}
    mock(Trickster).whim(5, 0.7){5}

    mock.instance_of(Member).do_deposit(50,'reaction_comment')
    mock.instance_of(Member).do_transfer(5, @m2, 'reaction_comment (received)')

    @a2.judge
   end    
   
   it 'should fall back to default amount if amount for reaction category is not set' do
    @m2 = Member.make(:app => @app)
    a2 = Activity.plan(:reaction, :category => 'foo', :app_token => @app.app_token, :member_token => @m.member_token, :member_b_token => @m2.member_token)
    @a2 = sign_n_make(a2,@app) 
 
    mock(App).find_by_app_token(@a2.app_token){@app} 

    mock(@app.settings.probabilities).default{0.7}
    mock(@app.settings.amounts.deposits.reaction).default{5}
    mock(@app.settings.percentages.transfers.reaction).default{10}  

    mock(Trickster).whim(5, 0.7){5}
    mock(Trickster).whim(1, 0.7){1}

    mock.instance_of(Member).do_deposit(50,"reaction foo")
    mock.instance_of(Member).do_transfer(1, @m2, 'reaction foo (received)')

    @a2.judge
   end

    
end
 