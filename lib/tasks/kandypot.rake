namespace :kandypot do 
  task :update_kandy_caches => :environment do
    
    if ENV['app_id'] 
      app = App.find_by_id(ENV['app_id'])
      app.update_members_kandy_cache if app
    else
      App.all.each do |app|
        app.update_members_kandy_cache
      end
    end
  
  end
end


