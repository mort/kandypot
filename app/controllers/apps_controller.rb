class AppsController < ApplicationController
  before_filter :require_auth
  
  def rewards
    @rewards = @app.settings.rewards
    render :template =>  'apps/rewards.json.rabl', :status => :ok
  end

end
