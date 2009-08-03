class ActivitiesController < ApplicationController
  before_filter :require_app
  
  def create
    params.delete_if{|k,v| !Activity.column_names.include?(k) }
    @activity = @app.activities.build(params)
    @activity.ip =  request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_CLIENT_IP'] || request.env['REMOTE_ADDR']))
    
    if @activity.save
      render :json => @activity.to_json, :status => :created 
    elsif @activity.errors.on(:authentication)
      render :text => '', :status => :forbidden
    else
      render :json => @activity.errors.to_json, :status => :bad_request  
    end
  end

end
