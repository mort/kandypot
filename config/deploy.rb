##########################
#  PARÁMETROS GENERALES  #
##########################
set :application,  "kandypot"
set :repository,   "ssh://soviet/var/opt/git/kandypot"
set :deploy_to,    "/var/www/#{application}"
set :server_group, 'www-data'
set :myfilesdir,   'myfiles'
set :runner,       'deploys'
set :user,         'deploys'

#########
#  SCM  #
#########
set :scm,         :git
set :branch,      "master"
set :scm_verbose, false    # para depurar
set :scm_user,    'deploys'
set :git_enable_submodules, 1

#####################
# FORMA DE DEPLOYAR #
#####################
set :deploy_via, :copy
set :keep_releases, 5
default_run_options[:pty] = true
ssh_options[:paranoid] = false

##############
#  MAQUINAS  #
##############
#
set :kandypot, '192.168.10.158'
set :soviet,   '192.168.10.170'

#########
# ROLES #
#########
role :web,      kandypot
role :app,      kandypot
role :migrator, kandypot
role :db,       kandypot, { :primary => true }
role :mirror,   soviet, { :no_release => true }

#####################
## PERSONALIZACIÓN ##
#####################

before "deploy:update_code", :update_mirror
after  "deploy:update_code", :link_database_config, :run_migrations
after  "deploy:update", "deploy:cleanup"
after  "deploy:symlink", "deploy:update_crontab"

###############
##  TAREAS   ##
###############
task :update_mirror, :roles => [:mirror] do
  run "cd /var/opt/git/kandypot/ && git fetch"
end

desc "Restart Application"
deploy.task :restart, :roles => [:app] do
  run "touch #{current_path}/tmp/restart.txt"
end

desc "Migraciones"
task :run_migrations, :roles => :migrator do
  run <<-CMD
    export RAILS_ENV=production &&
    cd #{release_path} &&
    rake db:migrate
  CMD
end

desc "Link the database yaml config"
task :link_database_config, :roles => [:app] do
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

#require 'hoptoad_notifier/capistrano'
