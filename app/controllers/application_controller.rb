# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :signature, :app_token

  private
  
  def require_app
    
    @app = App.find_by_id params[:app_id]

    unless @app.nil?   
      my_params = params.dup
      my_params = clean_params(my_params)
      
      my_params = my_params.merge('date_scope' => Time.now.midnight.utc.iso8601)

      par_str = my_params.sort.map{|j| j.join('=')}.join('&')
      str = Digest::SHA1.hexdigest(par_str)

      #logger.info("2 - #{my_params.inspect} par_str:#{par_str} str: #{str}  signature: #{params[:signature]}")          

      render :text => '', :status => :forbidden unless @app.authenticate(str, params[:signature])
                
    else
      render :text => '', :status => :not_found 
    end  
  end
  
  def clean_params(my_params)

    %w(signature format ip).each do |p|
      my_params.delete(p)
    end
    
    request.path_parameters.each do |k,v|
      my_params.delete(k)
    end
    
    #logger.info("Params auth #{my_params.inspect}")
    return my_params
  end
  
  
  
  
end