class BadgeObserver < ActiveRecord::Observer
  observe :activity
  
  require 'badges'
  
  def after_create(activity)
    app = activity.app
    badges = app.badges
    
    badges.each { |badge| 
      badge.process(activity) 
    } unless badges.blank?
      
  end
  
  
end
