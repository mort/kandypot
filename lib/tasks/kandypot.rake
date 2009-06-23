task :update_kandy_caches => :environment do

  m = ENV['app_id'] ? App.find_by_id(ENV['app_id']).members : Member  
  m.update_every_kandy_cache unless m.nil?
  
end


