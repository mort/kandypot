ActionController::Routing::Routes.draw do |map|
   
  map.subdomain :model => :app, :namespace => nil, :path_prefix => 'api' do |app|
    app.resources :activities, :only => [:create]
    app.resources :members, :only => [:show, :index]
    app.resources :notifications, :only => [:index]
    app.resources :badges, :only => [:index]
    
    app.connect 'settings/rewards', :controller => 'apps', :action => 'rewards'
    
  end

  # These resources do exist but we don't wanna to expose them to the world (yet)

  # map.resources :operation_logs
  # map.resources :kandy_ownerships
  # map.resources :kandies
  
end
