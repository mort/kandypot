class ActivitiesController < ApplicationController
  before_filter :require_app
  
  def create
    ip =  (request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_CLIENT_IP'] || request.env['REMOTE_ADDR'])

    activity_params = params.select {|k,v| Activity::API_PARAMS.include?(k) }.merge(:ip => ip)

    @activity = @app.activities.build(activity_params)
        
    if @activity.save
      render :json => @activity.to_json, :status => :created 
    else
      render :json => @activity.errors.to_json, :status => :bad_request  
    end
  end

end
