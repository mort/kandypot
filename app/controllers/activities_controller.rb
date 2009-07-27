class ActivitiesController < ApplicationController
  before_filter :require_app
  
  def create
    params.delete_if{|k,v| !Activity.column_names.include?(k) }
    @activity = @app.activities.build(params)
    if @activity.save
      render :json => @activity.to_json, :status => :created
    elsif @activity.errors.size > 1
      render :json => @activity.errors.to_json, :status => :bad_request    
    elsif @activity.errors.on(:authentication)
      render :text => '', :status => :forbidden
    end
  end

end
