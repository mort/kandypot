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
    activity = Activity.new(a)
    activity.should be_valid
  end
  
  it 'should create well formed activities (reaction_*)' do
    a = Activity.plan(:reaction, :credentials_app_token => @app.app_token)
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