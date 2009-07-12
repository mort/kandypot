task :update_kandy_caches => :environment do

  m = ENV['app_id'] ? App.find_by_id(ENV['app_id']).members : Member  
  m.update_every_kandy_cache unless m.nil?
  
  if m.kind_of?(App)
    m.update_attribute(:updated_at, Time.now)
  else
      
  end
  
  
  if ENV['app_id'] 
    app = App.find_by_id(ENV['app_id'])
    app.update_members_kandy_cache if app
  else
    App.all.each do |app|
      app.update_members_kandy_cache
    end
  end
  
end


