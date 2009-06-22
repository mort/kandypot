require File.dirname(__FILE__) + '/../spec_helper'

describe Activity, 'detecting type' do
  before do
    @app = App.make
  end

  it 'should categorize content creation activities' do
    a = Activity.plan(:activity_type => 'content_creation', :credentials_app_token => @app.app_token)
    activity = Activity.new(a)
    Activity.kind_of?(activity.activity_type).should == :content_creation
  end
  
  it 'should categorize reaction activities' do
    a = Activity.plan(:activity_type => 'reaction_comment', :credentials_app_token => @app.app_token)
    activity = Activity.new(a)
    Activity.kind_of?(activity.activity_type).should == :reaction
  end
  
  it 'should return false on unknown activities' do
    a = Activity.plan(:activity_type => 'foo', :credentials_app_token => @app.app_token)
    activity = Activity.new(a)
    Activity.kind_of?(activity.activity_type).should be_false
  end
  
end


describe Activity, 'validation' do
  before do
    @app = App.make
  end
  
  it 'should create well formed activities (content_creation)' do
    a = Activity.plan(:credentials_app_token => @app.app_token)
    
    params = {}
    params["member_token"]   = a[:member_token]
    params["content_token"]  = a[:content_token]
    params["content_type"]   = a[:content_type]
    params["content_source"] = a[:content_source]
    params["activity_type"]  = a[:activity_type]
    params["activity_at"]    = a[:activity_at]

    s = Digest::SHA1.hexdigest(params.to_s)   

   a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)

    mock(App).pack_up_params_for_signature(params){ s }
    mock(App).authenticate(a[:credentials_app_token], s, a[:credentials_signature]){true}
    
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should create well formed activities (reaction_*)' do
    a = Activity.plan(:reaction, :credentials_app_token => @app.app_token)
    
    
      params = {}
      params["member_token"]   = a[:member_token]
      params["content_token"]  = a[:content_token]
      params["content_type"]   = a[:content_type]
      params["content_source"] = a[:content_source]
      params["activity_type"]  = a[:activity_type]
      params["activity_at"]    = a[:activity_at]

      s = Digest::SHA1.hexdigest(params.to_s)   

     a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)

      mock(App).pack_up_params_for_signature(params){ s }
      mock(App).authenticate(a[:credentials_app_token], s, a[:credentials_signature]){true}
    
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should not create activities with unregistered reaction types' do
    a = Activity.plan(:reaction, :activity_type => 'reaction_foo', :credentials_app_token => @app.app_token) 
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
  it 'should not create activities of type reaction if content_owner_member_token is not present' do
    a = Activity.plan(:reaction, :content_owner_member_token => '', :credentials_app_token => @app.app_token)
    activity = Activity.new(a)
    activity.should_not be_valid
  end
  
end

describe Activity, 'authentication' do
  
  before do
    @app = App.make
    @a = Activity.plan(:credentials_app_token => @app.app_token)
  end
  
  it 'should authenticate well signed activities' do
    
    # SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
  
    mock(App).pack_up_params_for_signature(params){ s }
    mock(App).authenticate(@a[:credentials_app_token], s, @a[:credentials_signature]){true}
  
    a = Activity.new(@a)
    a.authenticated?.should be_true
  end
  
  it 'should not authenticate badly signed activities (bad app key)' do

     params = {}
     # SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
     params["member_token"]   = @a[:member_token]
     params["content_token"]  = @a[:content_token]
     params["content_type"]   = @a[:content_type]
     params["content_source"] = @a[:content_source]
     params["activity_type"]  = @a[:activity_type]
     params["activity_at"]    = @a[:activity_at]

     s = Digest::SHA1.hexdigest(params.to_s)   
     
     @a[:credentials_app_token] = @app.app_token
     @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, 'foo', s)

     mock(App).pack_up_params_for_signature(params){ s }
     mock(App).authenticate(@a[:credentials_app_token], s, @a[:credentials_signature]){false}
     
     # App.authenticate(self.credentials_app_token, packed_signature_params, self.credentials_signature)
     a = Activity.new(@a)
     a.authenticated?.should be_false
  end
  
  it 'should not authenticate badly signed activities (bad params string)' do

     params = {}
     # SIGNATURE_PARAMS = [:member_token, :content_token, :content_type, :content_source, :activity_type, :activity_at]
     params["member_token"]   = @a[:member_token]
     params["content_token"]  = @a[:content_token]
     params["content_type"]   = @a[:content_type]
     params["content_source"] = @a[:content_source]
     params["activity_type"]  = @a[:activity_type]
     params["activity_at"]    = @a[:activity_at]

     s = Digest::SHA1.hexdigest(params.to_s)   
     
     @a[:credentials_app_token] = @app.app_token
     @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, 'foo')

     mock(App).pack_up_params_for_signature(params){ s }
     mock(App).authenticate(@a[:credentials_app_token], s, @a[:credentials_signature]){false}
     
     # App.authenticate(self.credentials_app_token, packed_signature_params, self.credentials_signature)
     a = Activity.new(@a)
     a.authenticated?.should be_false
  end
  
 
end



 describe Activity, 'judgement' do
   before do
     @app = App.make
     @m = Member.make(:app => @app)
     a = Activity.plan(:credentials_app_token => @app.app_token, :member_token => @m.member_token)
     @a = sign_n_make(a,@app)     
   end
   
   it 'should include the Hammurabi module' do
     @a.should respond_to(:judge)
   end
   
   it 'should have methods for defined activity types' do
     @a.should respond_to("judge_content_creation".to_sym)
   end
   
   it 'should have a judge_reacion_comment method' do
     a = Activity.plan(:reaction, :credentials_app_token => @app.app_token, :member_token => @m.member_token)
     @a = sign_n_make(a,@app)
     @a.should respond_to('judge_reaction_comment')
   end
   
   
   it 'should reward content creation' do
     mock(App).find_by_app_token(@a.credentials_app_token){@app} 

     mock(@app.settings.probabilities).default {0.7}
     mock(@app.settings.amounts.deposits).content_creation {10}

     mock(Trickster).whim(10,0.7){10}

     mock.instance_of(Member).do_deposit(10,'content_creation')

     @a.judge
   end
   

   it 'should reward reaction comment' do
    @m2 = Member.make(:app => @app)
    a2 = Activity.plan(:reaction, :credentials_app_token => @app.app_token, :member_token => @m.member_token, :content_owner_member_token => @m2.member_token)
    @a2 = sign_n_make(a2,@app) 
 
    mock(App).find_by_app_token(@a2.credentials_app_token){@app} 

    mock(@app.settings.probabilities).default {0.7}
    mock(@app.settings.amounts.deposits).reaction_comment{5}
    mock(@app.settings.amounts.transfers).reaction_comment{3}  

    mock(Trickster).whim(5, 0.7){5}
    mock(Trickster).whim(3, 0.7){3}

    mock.instance_of(Member).do_deposit(5,'reaction_comment')
    mock.instance_of(Member).do_transfer(3, @m2, 'reaction_comment (received)')

    @a2.judge
   end    
   

 
 end
 