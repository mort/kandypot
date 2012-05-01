class ActivitiesController < ApplicationController
  before_filter :require_auth
  before_filter :whitelist_params, :only => :create
  verify :params => [:data, :app_id, :subdomains]

  def create
    @activity = @app.activities.build(params[:data].merge(:ip => remote_ip))

    if @activity.save
      @op = @activity.operation_log
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
