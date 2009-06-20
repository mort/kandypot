require File.dirname(__FILE__) + '/../spec_helper'
require 'hmac-sha1'

describe App, 'credendials and authentication' do

  before(:each) do
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


describe App, 'app settings' do
  
  before do
    @app = App.make(:nicename => 'iwanna')
  end
  
  it 'know when it has specific settings' do
    mock(File).exists?(@app.settings_filepath){true}
    @app.has_settings?.should be_true
  end
  
  it 'should return the path for its settings file' do
    @app.settings_filepath.should == Rails.root.join('config','app_settings',"#{@app.nicename}.yml").to_s
  end
  
  it 'should load the specific settings if they exist' do
    mock(@app).has_settings?{true}
    mock(Settings).new(@app.settings_filepath){'iwanna'}
    @app.settings.should == 'iwanna'
  end
  
  it 'should load default settings if specific dont exist' do
    mock(@app).has_settings?{false}
    mock(Settings).new(App.default_settings_path){'default'}
    @app.settings.should == 'default'
  end
  

end
