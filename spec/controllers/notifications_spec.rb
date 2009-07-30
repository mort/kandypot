require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationsController, 'get' do
  before do
    @app = App.make
    2.times { Notification.make(:app => @app) }    
    
    params = sign_request(@app)

    get :index, {:app_id => @app.nicename, :format => 'atom'}.merge(params) 
    
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