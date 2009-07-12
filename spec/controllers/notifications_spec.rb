require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationsController, 'get' do
  before do
    @app = App.make
    10.times { Notification.make(:app => @app) }
    d = Time.now.midnight.utc.iso8601
    str = Digest::SHA1.hexdigest(d)    
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @app.app_key, str)
    get :index, :app_id => @app.id, :format => 'atom', :signature => signature
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