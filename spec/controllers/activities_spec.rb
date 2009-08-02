require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController, 'create' do
  before do
    @app = App.make
  end
  
  it "should respond 201 on creation" do
    @a = Activity.plan(:app => @app)
    @a[:app_id] = @app.nicename        
    
    authenticate_with_http_digest(@app.app_key, @app.app_token, 'Kandypot')    
    
    post :create, @a.merge(:subdomains => :app_id)
        
    response.response_code.should == 201
  end
  
  
  it "should respond 401 on bad auth" do
    @a = Activity.plan(:app => @app)
    @a[:app_id] = @app.nicename        
    
    post :create, @a.merge(:subdomains => :app_id)
    
    response.response_code.should == 401
  end
  

  
  
end

