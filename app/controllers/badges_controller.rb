class BadgesController < ApplicationController
  before_filter :require_auth
  
  
  def index
    
    @badges = @app.badges
    render :template => 'badges/index.json.rabl', :status => :ok
  
  end
  
  
end