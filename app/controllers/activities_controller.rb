class ActivitiesController < ApplicationController
  before_filter :require_auth
  before_filter :whitelist_params, :only => :create
  
  def create
    ip =  (request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_CLIENT_IP'] || request.env['REMOTE_ADDR'])

    activity_params = params[:data].merge(:ip => ip)

    @activity = @app.activities.build(activity_params)
        
    if @activity.save
      render :json => @activity.to_json, :status => :created 
    else
      render :json => @activity.errors.to_json, :status => :bad_request  
    end
  end


  private
  
  def whitelist_params
    
    params[:data].each do |k,v|
      params[:data][k].delete unless Activity::API_PARAMS.include?(k.to_s)
    end
    
  end

end
