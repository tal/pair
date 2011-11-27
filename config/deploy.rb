require "bundler/capistrano"

set :application, "pair"
set :repository,  "git@github.com:Talby/pair.git"
set :user, 'pair'

set :shared_children, %w(public/system log tmp/pids tmp/sockets)

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
    run "cat #{shared_path}/pids/unicorn.pid.oldbin && kill -QUIT `cat #{shared_path}/pids/unicorn.pid.oldbin`"
  end

  task :migrate do ; end

  desc <<-DESC
  Prepares one or more servers for deployment. Before you can use any \
  of the Capistrano deployment tasks with your project, you will need to \
  make sure all of your servers have been prepared with `cap deploy:setup'. When \
  you add a new server to your cluster, you can easily run the setup task \
  on just that server by specifying the HOSTS environment variable:

  $ cap HOSTS=new.server.com deploy:setup

  It is safe to run this task on servers that have already been set up; it \
  will not destroy any deployed revisions or data.
  DESC
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d.split('/').last) }
    run "mkdir -p #{dirs.join(' ')}"
    run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
  end

  desc <<-DESC
  [internal] Touches up the released code. This is called by update_code \
  after the basic deploy finishes. It assumes a Rails project was deployed, \
  so if you are deploying something else, you may want to override this \
  task with your own environment's requirements.

  This task will make the release group-writable (if the :group_writable \
  variable is set to true, which is the default). It will then set up \
  symlinks to the shared directory for the log, system, and tmp/pids \
  directories, and will lastly touch all assets in public/images, \
  public/stylesheets, and public/javascripts so that the times are \
  consistent (so that asset timestamping works). This touch process \
  is only carried out if the :normalize_asset_timestamps variable is \
  set to true, which is the default The asset directories can be overridden \
  using the :public_children variable.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
    rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
    mkdir -p #{latest_release}/public &&
    mkdir -p #{latest_release}/tmp
    CMD
    shared_children.map do |d|
      run "ln -s #{shared_path}/#{d.split('/').last} #{latest_release}/#{d}"
    end

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
end

task :testmystuff do
  dirs = [deploy_to, releases_path, shared_path]
  dirs += shared_children.map { |d| File.join(shared_path, d.split('/').last) }
  puts dirs
end
