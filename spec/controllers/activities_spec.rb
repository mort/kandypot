require File.dirname(__FILE__) + '/../spec_helper'
include Rack::Test::Methods

describe ActivitiesController, 'create' do
  
  before do
    @app = create(:app) 
    authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)    
  end
  
  it "should respond 201 on creation" do
       
    data = {
      :verb => 'signup',
      :author_token => 'foo',
      :ip => '127.0.0.1'
    }   
               
    post 'create', :subdomains => :app_id, :data => data, :app_id => @app.nicename
    
    response.response_code.should == 201
  end
  
  
  # it "should respond 401 on bad auth" do
  #   a = attributes_for(:act,:app => @app)
  #   a[:app_id] = @app.nicename        
  #   
  #   post :create, :data => a.merge(:ip => '127.0.0.1'), :subdomains => :app_id, :app_id => @app.nicename
  #   
  #   response.response_code.should == 401
  # end
  

  
  
end

