require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController, 'create' do
  before do
    @app = App.make
  end
  
  it "should respond 201 on creation" do
    @a = Activity.plan(:app => @app)
    @a[:app_id] = @app.nicename        
            
    options = @a.dup
                
    #mock(Activity).new(@a){@activity}
    #mock(@activity).save{true}
    
    options.delete(:ip)    
    options.delete(:app_token)
    app_id = options.delete(:app_id)
    
    params = sign_request(@app, options)
    
    post :create, @a.merge(params)
    
    response.response_code.should == 201
  end
  
  
  it "should respond 403 on bad signature" do
    @a = Activity.plan(:app => @app)
    @a[:app_id] = @app.nicename        
    
    options = @a.dup

    options.delete(:ip)    
    options.delete(:app_token)
    app_id = options.delete(:app_id)

    params = sign_request(@app, options)
    params[:signature] = 'foo'
    
    post :create, @a.merge(params)
    
    response.response_code.should == 403
  end
  

  
  
end

