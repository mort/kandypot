ActionController::Routing::Routes.draw do |map|
   
  map.subdomain :model => :app, :namespace => nil do |app|
    app.resources :activities, :only => [:create]
    app.resources :members, :only => [:show, :index]
    app.resources :notifications, :only => [:index]
  end

  # These resources do exist but we don't wanna to expose them to the world (yet)

  # map.resources :operation_logs
  # map.resources :kandy_ownerships
  # map.resources :kandies
  
end
