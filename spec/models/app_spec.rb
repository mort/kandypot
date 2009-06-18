require File.dirname(__FILE__) + '/../spec_helper'

describe App do

  before do
    # This will make a Comment, a Post, and a User (the author of
    # the Post), and generate values for all their attributes:
    @app = App.make
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

  
end

