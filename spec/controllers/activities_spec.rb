require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController, 'create' do
  before do
    @app = App.make
  

  end
  
  it "should respond 201 on creation" do
    
    @a = Activity.plan(:credentials_app_token => @app.app_token)
    
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
    
    @activity = {}
    @a.each do |k,v|
      @activity[k.to_s] = v
    end
    
    mock(Activity).new(@activity){@activity}
    mock(@activity).save{true}

    post :create, @a
    response.response_code.should == 201
  end
  
  
  it "should respond 403 on bad signature" do
    
    @a = Activity.plan(:credentials_app_token => @app.app_token)
    
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = 'foo'
    
    @activity = {}
    @a.each do |k,v|
      @activity[k.to_s] = v
    end
    
    post :create, @a
    response.response_code.should == 403
  end
  
  
  it "should respond 403 on bad app token" do
    
    @a = Activity.plan(:credentials_app_token => 'foo')
    
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
    
    @activity = {}
    @a.each do |k,v|
      @activity[k.to_s] = v
    end
    
    post :create, @a
    response.response_code.should == 403
  end
  
  
  it "should respond 403 on bad app token" do
    
    @a = Activity.plan(:credentials_app_token => 'foo')
    
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
    
    @activity = {}
    @a.each do |k,v|
      @activity[k.to_s] = v
    end
    
    post :create, @a
    response.response_code.should == 403
  end
  
  it "should respond 400 on missing params" do
    
    @a = Activity.plan(:credentials_app_token => @app.app_token)
    
    params = {}
    params["member_token"]   = @a[:member_token]
    params["content_token"]  = @a[:content_token]
    params["content_type"]   = @a[:content_type]
    params["content_source"] = @a[:content_source]
    params["activity_type"]  = @a[:activity_type]
    params["activity_at"]    = @a[:activity_at]
    
    s = Digest::SHA1.hexdigest(params.to_s)   
    
    @a[:credentials_signature] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, s)
    
    @a.delete(:activity_type)

    @activity = {}
    @a.each do |k,v|
      @activity[k.to_s] = v
    end
    
    #mock(Activity).new(@activity){@activity}
    #mock(@activity).save{false}

    post :create, @a
    response.response_code.should == 400
  end
  
  
  
  
end

