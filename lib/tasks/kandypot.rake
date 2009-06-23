task :update_kandy_caches => :environment do

  m = if ENV['app_id']
    App.find(ENV['app_id']).members
  else
    Member
  end
  
  m.update_every_kandy_cache
  
  RAILS_DEFAULT_LOGGER.flush
end


