class NotificationsController < ApplicationController
  before_filter :require_auth
  
  def index
    @notifications = @app.notifications.all :limit => Settings.apps.notifications_limit
    respond_to do |format|
      format.atom
    end
  end
  
end
