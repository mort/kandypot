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

#####################
## PERSONALIZACIÓN ##
#####################

before "deploy:update_code", :update_mirror
after  "deploy:update_code", :run_migrations
after  "deploy:update", "deploy:cleanup"


###############
##  TAREAS   ##
###############
task :update_mirror, :roles => [:mirror] do
  run "cd /var/opt/git/#{application}/ && git pull #{ scm_verbose ? "-q" : "" } origin #{branch}"
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

