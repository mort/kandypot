class MembersController < ApplicationController
  before_filter :require_app
  
  def show
    @member = @app.members.find_by_member_token(params[:id])
    if @member
      render :json => {:member_token => @member.member_token, :kandies_count => @member.kandies_count}, :status => :ok
    else
      render :text => '', :status => :not_found  
    end
  end
  
  private
  
  def require_app
    @app = App.find_by_id params[:app_id]
    unless @app
      render :text => '', :status => :not_found 
    else
      str = Digest::SHA1.hexdigest("#{params[:id]}###{Time.now.midnight.to_s}")    
      render :text => '', :status => :forbidden unless App.authenticate(@app.app_token, str, params[:signature])
    end  
  end

end
