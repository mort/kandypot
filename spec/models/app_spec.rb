require File.expand_path('../../spec_helper', __FILE__)
require 'hmac-sha1'

describe App, 'credendials and authentication' do

  before(:each) do
    @app = create(:app)
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

end


describe App, 'app settings' do

  before do
    @app = App.create(:nicename => 'iwanna')
  end

  it 'know when it has specific settings' do
    #mock(File).exists?(@app.settings_filepath){true}
    File.stub!(:exists?).and_return(true)
    @app.has_settings?.should be_true
  end

  it 'should return the path for its settings file' do
    @app.settings_filepath.should == Rails.root.join('config','app_settings',"#{@app.nicename}.yml").to_s
  end

  it 'should load the specific settings if they exist' do
    #mock(@app).has_settings?{true}
    #mock(Settings).new(@app.settings_filepath){'iwanna'}

    @app.settings[:app].should == 'iwanna'
  end

  it 'should load default settings if specific dont exist' do
    #mock(@app).has_settings?{false}
    #mock(Settings).new(App.default_settings_path){'default'}
    File.stub!(:exists?).and_return(false)
    @app.settings[:app].should == 'default'
  end


end

describe App do

  before do
    #@app = App.make(:nicename => 'iwanna')
  end


  #it 'should update kandy cache for all members' do
    #mock.instance_of(Member).update_kandy_cache
    #@app.update_members_kandy_cache
  #end

end


# == Schema Information
#
# Table name: apps
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  nicename      :string(255)
#  url           :string(255)
#  app_key       :string(255)
#  app_token     :string(255)
#  ip            :string(15)
#  description   :text
#  members_count :integer(4)      default(0), not null
#  kandies_count :integer(4)      default(0), not null
#  status        :integer(2)      default(1), not null
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_apps_on_name       (name) UNIQUE
#  index_apps_on_nicename   (nicename) UNIQUE
#  index_apps_on_url        (url) UNIQUE
#  index_apps_on_app_key    (app_key) UNIQUE
#  index_apps_on_app_token  (app_token) UNIQUE
#  index_apps_on_ip         (ip) UNIQUE
#

