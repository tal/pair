require "bundler/capistrano"

set :application, "pair"
set :repository,  "git@github.com:Talby/pair.git"
set :user, 'pair'

set :scm, :git

set :rvm_type, :user

role :web, "72.14.179.30"
role :app, "72.14.179.30"
#role :db,  "72.14.179.30", :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    
  end
end
