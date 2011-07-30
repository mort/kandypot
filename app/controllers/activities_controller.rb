class ActivitiesController < ApplicationController
  before_filter :require_auth
  before_filter :whitelist_params, :only => :create
  verify :params => [:data, :app_id, :subdomains]
  
  def create
    ip =  (request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_CLIENT_IP'] || request.env['REMOTE_ADDR'])

    activity_params = params[:data].merge(:ip => ip)
    logger.debug("P: #{activity_params}")

    @activity = @app.activities.build(activity_params)
    
    logger.debug("Activity: valid? #{@activity.valid?} / #{@activity.errors.full_messages.inspect}")
        
    if @activity.save
      @op = @activity.operation_log
      logger.debug("OP: #{@op.inspect}")    
      render :template => 'operation_logs/show.json.rabl', :status => :created 
    else
      logger.debug("OP: #{@activity.errors.inspect}")    
      render :template =>  'activities/errors.json.rabl', :status => :bad_request  
     end
  
  end


  private
  
  def whitelist_params
  
    params[:data].each do |k,v|
      params[:data].delete(k) unless Activity::API_PARAMS.include?(k.to_sym)
    end
    
  end

end
