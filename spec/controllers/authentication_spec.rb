require File.expand_path('../../spec_helper', __FILE__)

class FooController < ApplicationController

  before_filter :require_auth

  def bar
    render text: "Bar!"
  end
end

ActionController::Routing::Routes.draw do |map|
  map.subdomain :model => :app, :namespace => nil, :path_prefix => 'api' do |app|
    app.connect 'foo/bar', :controller => 'foo', :action => 'bar'
  end
end

describe FooController, "require_auth filter" do
  context "when no param app_id is provides" do
    it "should return 404 status code" do
      lambda {
        get :bar, subdomains: :app_id
      }.should raise_error(ActionController::RoutingError)
    end
  end

  context "when param app_id is invalid" do
    it "should return 404 status code" do
      lambda {
        get :bar, app_id: '1234', subdomains: :app_id
      }.should raise_error(ActionController::RoutingError)
    end
  end

  context "when param app_id is valid" do
    before do
      @app = create(:app)
      @request.host = @app.nicename + '.test.host'
    end

    context "and app_key is invalid" do
      it "should not authorize the request" do
        authenticate_with_http_digest("", @app.app_token, @app.api_auth_realm)

        get :bar, app_id: @app.nicename, subdomains: :app_id

        response.response_code.should == 401
      end
    end

    context "and app_key is valid" do
      it "should not authorize the request" do
        authenticate_with_http_digest(@app.app_key, @app.app_token, @app.api_auth_realm)

        get :bar, app_id: @app.nicename, subdomains: :app_id

        response.response_code.should == 200
        response.body.should == "Bar!"
      end
    end

  end

end
