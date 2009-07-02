# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  private
  
  def require_app
    @app = App.find_by_id params[:app_id]
    unless @app
      render :text => '', :status => :not_found 
    else
      d = Time.now.midnight.utc.iso8601
      u = @app.ip
      str = Digest::SHA1.hexdigest(d)    
      render :text => '', :status => :forbidden unless App.authenticate(@app.app_token, str, params[:signature])
    end  
  end
  
end
