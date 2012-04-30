require File.expand_path('../../spec_helper', __FILE__)

describe NotificationsController, 'get' do
  before do
    @app = create(:app)
    2.times { create(:notification,:app => @app) }

    authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)
    #request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Digest.encode_credentials("GET", @app.app_key, @app.app_token, true)

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
