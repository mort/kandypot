class BadgeObserver < ActiveRecord::Observer
  observe :activity
  
  require 'badges'
  
  def after_create(activity)
    app = activity.app
    badges = app.badges
    
    unless badges.blank?
      badges.each do |badge|
         procesor = "Kandypot::Badges::Processors::#{badge.badge_type.camelize}Processor".constantize
         procesor.process(activity, badge)
      end
    
    end
    
    
  end
  
  
end
