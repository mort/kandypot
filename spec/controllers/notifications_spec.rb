require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationsController, 'get' do
  before do
    @app = App.create
    2.times { Notification.create(:app => @app) }    
    
    authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)    
    
    get :index, :app_id => @app.nicename, :format => 'atom', :subdomains => :app_id
    
  end
  
  it 'should respond with success' do  
    response.response_code.should == 200
  end
  
  it 'should respond with a valid feed' do  
    #response.should be_valid_feed
    #assert_valid_feed
    pending
  end
  
end