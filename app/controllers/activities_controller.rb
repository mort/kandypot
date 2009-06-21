class ActivitiesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  VALID_SUBJECTS = ['content_creation', 'reaction_comment', 'reaction_favorite', 'reaction_other']
  ACTIVITY_PARAMS = [:credentials_consumer_token, :credentials_consumer_key, :subject, :member_token, :content_token, :type_of_content, :content_owner_member_token, :activity_date]
        
  def create
    validate_params
    activity = params
    # Get rid of non-activity params
    activity.delete_if{|k,v| !REPORT_PARAMS.include?(k.to_sym)}
    
    @activity = Activity.new(activity)
    if @activity.save
      # Justice Shall Prevail
      #h = Hammurabi.new(activity)
      #h.judge
      #Bj.submit "rake hammurabi:judge activity_id=#{@activity.id}"
      raise HTTPStatus::OK, 'The activity has been created'
    end
  end
  
  private
  
  def validate_params
    
            
    # Check for credentials
    raise HTTPStatus::Forbidden, 'Missing consumer credentials' unless (params[:credentials_app_token] && params[:credentials_signature])
    
    # Check for common mandatory params
    raise HTTPStatus::BadRequest, 'Missing activity data' unless (params[:subject] && VALID_SUBJECTS.include?(params[:subject]) && params[:member_token] && params[:content_token])

    # Check for mandatory params for every kind of activity        
    case params[:subject]
      when 'content_creation'
        raise HTTPStatus::BadRequest, 'Missing activity data' unless params[:type_of_content]
      when 'reaction_comment', 'reaction_favorite', 'reaction_other'
        raise HTTPStatus::BadRequest, 'Missing activity data' unless params[:content_owner_member_token]  
    end
    
    # Check for the existence of the consumer app
    consumer = Consumer.find_by_consumer_token(params[:credentials_consumer_token])
    raise HTTPStatus::NotFound if consumer.nil?
    
    # Authenticate the consumer app
    # Obscurity => We raise Not Found if the authentication process happens to fail
    raise HTTPStatus::NotFound unless (consumer.authenticate())

  end
end
