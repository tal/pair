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

  desc 'Start app from cold'
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && unicorn_rails -c #{current_path}/config/unicorn.rb -E production -D"
  end

  desc 'Stop app'
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "kill -QUIT `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc 'Restart app'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "kill -USR2 `cat #{shared_path}/pids/unicorn.pid`"
  end

  task :migrate do ; end
end
