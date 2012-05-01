class ApplicationController < ActionController::Base
  helper :all
  filter_parameter_logging :signature, :app_token

  def remote_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_CLIENT_IP'] || request.env['REMOTE_ADDR']
  end

  private

  def require_auth
    unless @app = App.find_by_nicename(params[:app_id])
      render :text => '', :status => :not_found and return false
    end

    success = authenticate_or_request_with_http_digest(@app.api_auth_realm) do |app_key|
      if (@app.app_key == app_key)
        Digest::MD5::hexdigest([@app.app_key, @app.api_auth_realm, @app.app_token].join(":"))
      end
    end

    unless success
      request_http_digest_authentication(@app.api_auth_realm, "Authentication failed") and return false
    end
    return true
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
