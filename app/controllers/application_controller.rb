class ApplicationController < ActionController::Base
  helper :all 
  filter_parameter_logging :signature, :app_token

  private
  
  def require_auth
     @app = App.find_by_nicename params[:app_id]
     
     unless @app.nil?   
       realm = @app.api_auth_realm
       
      success = authenticate_or_request_with_http_digest(realm) do |app_key|     
        Digest::MD5::hexdigest([@app.app_key, @app.api_auth_realm, @app.app_token].join(":"))  if (@app.app_key == app_key)
      end
      
      request_http_digest_authentication(@app.api_auth_realm, "Authentication failed") unless success
     else
       render :text => '', :status => :not_found 
     end  
   end
  
  def clean_params(my_params)

    %w(signature format ip app_id).each do |p|
      my_params.delete(p)
    end
    
    request.path_parameters.each do |k,v|
      my_params.delete(k)
    end
    
    return my_params
  end
  
  
  
  
end