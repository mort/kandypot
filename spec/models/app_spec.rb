require File.dirname(__FILE__) + '/../spec_helper'
require 'hmac-sha1'

describe App do

  before do
    # This will make a Comment, a Post, and a User (the author of
    # the Post), and generate values for all their attributes:
    @app = App.make
  end

  it "should have an app token" do
    @app.app_token.should_not be_nil    
  end
  
  it "should have an app key" do
    @app.app_key.should_not be_nil    
  end
  
  it "credentials should equal length" do
    @app.app_token.size.should ==  @app.app_key.size
  end

  it 'should find the app by app_token' do
    app = App.find_by_app_token(@app.app_token)
    app.should_not be_nil
  end
  
  it 'should pack up a params hash for signature prior to authentication' do
    params = {:foo => 'bar', :wadus => 'raur'}
    
    App.pack_up_params_for_signature(params).class.should == String
  end

  it "should authenticate with valid credentials" do
    
    data = 'loremipsum'
    stub(App).pack_up_params_for_signature(:foo => 'bar', :wadus => 'raur'){data}
    
    app_key = @app.app_key
    app_token = @app.app_token
    
    signature = HMAC::SHA1.hexdigest(app_key, data)
    
    App.authenticate(app_token, data, signature).should be_true
  end
  
  
  it "should not authenticate with invalid credentials" do
    
    data = 'loremipsum'
    stub(App).pack_up_params_for_signature(:foo => 'bar', :wadus => 'raur'){data}
    
    app_key = @app.app_key
    app_token = @app.app_token
    
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, app_key, data) 
    
    App.authenticate(app_token, 'wadus', signature).should be_false
    App.authenticate(app_token, data, 'wadus').should be_false
  end
  
  
end

