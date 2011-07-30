require File.dirname(__FILE__) + '/../spec_helper'
#include Rack::Test::Methods

describe ActivitiesController, 'create' do
  integrate_views
  
  before do
    Trickster.should_receive(:modulate).with(anything()).and_return(1)          
    
    @app = create(:app) 
    @request.host = "#{@app.nicename}.example.com"
    
  end
  
  context 'singular' do
    
    before(:each) do
     @data = {
         :verb => 'signup',
         :actor_token => 'f'*32,
         :ip => '127.0.0.1',
         :published => Time.now.to_s
       }
    end
    
    it 'should create an activity' do
   

       authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)
       
       lambda{
          post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data
       }.should change(@app.activities, :count).by(1)
  
    end
    
    it 'should create an operation log' do

       authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)
       
       lambda{
          post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data
       }.should change(OperationLog, :count).by(1)
  
    end
        
    it "should give the right response" do
    
      authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   
                    
      post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

      response.response_code.should == 201
      response.body.should_not be_blank
      
      r =  ActiveSupport::JSON.decode(response.body)
      
      r.should be_instance_of(Hash)
      
      act = Activity.last
      
      r["apiVersion"].should_not be_nil
      r["id"].should_not be_nil
      r["method"].should_not be_nil
      r["method"].should == 'activities/create'
      
      r["data"].should_not be_nil
      
      r["data"]['kind'].should == 'OperationLog'

      r['data']['do_reward'].should be_true
      r['data']['do_transfer'].should be_false
      r['data']['do_badges'].should be_nil
      
      r['data']['reward_amount'].should_not be_nil
      r['data']['transfer_amount'].should be_nil

      r['data']['activity_uuid'].should == act.uuid
      r['data']['category'].should == 'singular'
      r['data']['actor_token'].should == act.actor_token
      r['data']['p'].should_not be_nil
      r['data']['modulated_p'].should == 1
      
    
    end
  
  end
  
  context 'creation' do 
    
      before(:each) do
       @data = {
           :verb => 'post',
           :actor_token => 'f'*32,
           :object_url => 'http://foo.com/wadus',
           :object_type => 'foo',
           :ip => '127.0.0.1',
           :published => Time.now.to_s
         }
         
      end
      
      it "should give the right response" do

        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   

        post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

        response.response_code.should == 201
        response.body.should_not be_blank

        r =  ActiveSupport::JSON.decode(response.body)

        r.should be_instance_of(Hash)

        act = Activity.last

        r["apiVersion"].should_not be_nil
        r["id"].should_not be_nil
        r["method"].should_not be_nil
        r["method"].should == 'activities/create'

        r["data"].should_not be_nil

        r["data"]['kind'].should == 'OperationLog'

        r['data']['do_reward'].should be_true
        r['data']['do_transfer'].should be_false
        r['data']['do_badges'].should be_nil

        r['data']['reward_amount'].should_not be_nil
        r['data']['transfer_amount'].should be_nil

        r['data']['activity_uuid'].should == act.uuid
        r['data']['category'].should == 'creation'
        r['data']['actor_token'].should == act.actor_token
        r['data']['p'].should_not be_nil
        r['data']['modulated_p'].should == 1


      end
      
  end
  
  context 'reaction' do

       before(:each) do
        
        @data = {
            :verb => 'comment',
            :actor_token => 'f'*32,
            :target_url => 'http://foo.com/wadus',
            :target_type => 'foo',
            :target_author_token => 'a'*32,
            :ip => '127.0.0.1',
            :published => Time.now.to_s
          }

       end

       it "should give the right response" do

         authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   

         post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

         response.response_code.should == 201
         response.body.should_not be_blank
         

         r =  ActiveSupport::JSON.decode(response.body)

         r.should be_instance_of(Hash)
         
         act = Activity.last

         r["apiVersion"].should_not be_nil
         r["id"].should_not be_nil
         r["method"].should_not be_nil
         r["method"].should == 'activities/create'

         r["data"].should_not be_nil

         r["data"]['kind'].should == 'OperationLog'

         r['data']['do_reward'].should be_true
         r['data']['do_transfer'].should be_true
         r['data']['do_badges'].should be_nil

         r['data']['reward_amount'].should_not be_nil
         r['data']['transfer_amount'].should_not be_nil

         r['data']['activity_uuid'].should == act.uuid
         r['data']['category'].should == 'reaction'
         r['data']['actor_token'].should == act.actor_token
         r['data']['transfer_recipient_token'].should == act.target_author_token
         
         r['data']['p'].should_not be_nil
         r['data']['modulated_p'].should == 1


       end

  end
    
  context 'interaction' do

     before(:each) do
       @data = {
         :verb => 'dm',
         :actor_token => 'f'*32,
         :target_type => 'person',
         :target_token => 'a'*32,
         :ip => '127.0.0.1',
         :published => Time.now.to_s
       }
     end

      it "should give the right response" do

        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   

        post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

        response.response_code.should == 201
        response.body.should_not be_blank

        r =  ActiveSupport::JSON.decode(response.body)

        r.should be_instance_of(Hash)

        act = Activity.last

        r["apiVersion"].should_not be_nil
        r["id"].should_not be_nil
        r["method"].should_not be_nil
        r["method"].should == 'activities/create'

        r["data"].should_not be_nil

        r["data"]['kind'].should == 'OperationLog'

        r['data']['do_reward'].should be_true
        r['data']['do_transfer'].should be_true
        r['data']['do_badges'].should be_nil

        r['data']['reward_amount'].should_not be_nil
        r['data']['transfer_amount'].should_not be_nil

        r['data']['activity_uuid'].should == act.uuid
        r['data']['category'].should == 'interaction'
        r['data']['actor_token'].should == act.actor_token
        r['data']['transfer_recipient_token'].should == act.target_token

        r['data']['p'].should_not be_nil
        r['data']['modulated_p'].should == 1


      end

   end
  
  context 'with badge newbish' do
     before(:each) do
       
       @badge = create(:newbish_badge, :app => @app, :verb => 'post')
       
       @data = {
           :verb => 'post',
           :actor_token => 'f'*32,
           :object_url => 'http://foo.com/wadus',
           :object_type => 'foo',
           :ip => '127.0.0.1',
           :published => Time.now.to_s
         }
     end
     
     it 'should create a badge grant' do


        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)

        lambda{
           post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data
        }.should change(BadgeGrant, :count).by(1)

     end
     
     
     it "should give the right response" do

       authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   

       post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

       response.response_code.should == 201
       response.body.should_not be_blank
       
       act = Activity.last
       
       r =  ActiveSupport::JSON.decode(response.body)

       r.should be_instance_of(Hash)
       
       r["apiVersion"].should_not be_nil
       r["id"].should_not be_nil
       r["method"].should_not be_nil
       r["method"].should == 'activities/create'

       r["data"].should_not be_nil

       r["data"]['kind'].should == 'OperationLog'

       r['data']['do_reward'].should be_true
       r['data']['do_transfer'].should be_false
       r['data']['do_badges'].should be_true

       r['data']['reward_amount'].should_not be_nil
       r['data']['transfer_amount'].should be_nil

       r['data']['activity_uuid'].should == act.uuid
       r['data']['category'].should == 'creation'
       r['data']['actor_token'].should == act.actor_token
       r['data']['p'].should_not be_nil
       r['data']['modulated_p'].should == 1
       
       r['data']['badges'].should be_instance_of(Hash)
       r['data']['badges'][act.actor_token].should be_instance_of(Hash)
       r['data']['badges'][act.actor_token]['badge_description'].should == @badge.description
       r['data']['badges'][act.actor_token]['badge_title'].should == @badge.title

    end 
     
  end
  
   
  # it "should respond 401 on bad auth" do
  #   a = attributes_for(:act,:app => @app)
  #   a[:app_id] = @app.nicename        
  #   
  #   post :create, :data => a.merge(:ip => '127.0.0.1'), :subdomains => :app_id, :app_id => @app.nicename
  #   
  #   response.response_code.should == 401
  # end
  # 
  # 
  # def app
  #   ActionController::Dispatcher.new
  # end
  # 
end



describe ActivitiesController, 'with errors' do
   integrate_views
   
     before(:each) do

        @app = create(:app) 
        @request.host = "#{@app.nicename}.example.com"
        #@b = create(:newbish_badge, :app => @app, :qtty => 1)

     
       @data = {
           :verb => 'post',
           :actor_token => 'f'*32,
           :object_type => 'foo',
           :ip => '127.0.0.1',
           :published => Time.now.to_s
         }

     end
   
     it 'should not create an activity' do
  
        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)
      
        lambda{
           post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data
        }.should_not change(@app.activities, :count).by(1)
 
     end
   
     it 'should not create an operation log' do

        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)
      
        lambda{
           post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data
        }.should_not change(OperationLog, :count).by(1)
 
     end
       
     it "should give the right response" do
          
      authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)   
                
      post 'create', :subdomains => :app_id, :app_id => @app.nicename, :data => @data

      response.response_code.should == 400
      response.body.should_not be_blank
  
      r =  ActiveSupport::JSON.decode(response.body)
  
      r.should be_instance_of(Hash)
  
      act = Activity.last
  
      r["apiVersion"].should_not be_nil
      r["id"].should_not be_nil
      r["method"].should_not be_nil
      r["method"].should == 'activities/create'
  
      r["data"].should be_nil
      r["errors"].should be_instance_of(Hash)
      r['errors'].size.should == 1
      
      
    end

 
 end

