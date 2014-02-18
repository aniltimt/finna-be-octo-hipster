require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :use_sudo, false
set :stages, %w(prod dev)
set :deploy_via, :remote_cache
set :default_stage, "dev"
set :shared_children, fetch(:shared_children) + %w(public/assets assets config)

set :application, "cti"
set :scm, :git
set :repository,  "git@git.freshlimestudio.com:projects/#{application}"

set :rake,           "rake"
set :rails_env,      "production"
set :migrate_env,    ""
set :migrate_target, :current

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :deploy do

  desc "Tail log file"
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && #{bundle_command} exec whenever --update-crontab #{application}"
  end

end

namespace :uploads do

  desc "Creates the upload folders unless they exist and sets the proper upload permissions."
  task :setup, :except => { :no_release => true } do
    dirs = uploads_dirs.map { |d| File.join(shared_path, d) }
    run "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
  end

  desc "[internal] Creates the symlink to uploads shared folder for the most recently deployed version."
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/assets"
    run "rm -rf #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/public/assets #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"
  end

  desc "[internal] Computes uploads directory paths and registers them in Capistrano environment."
  task :register_dirs do
    set :uploads_dirs,    %w( assets public/assets )
    set :shared_children, fetch(:shared_children) + fetch(:uploads_dirs)
  end

  after 'deploy:update_code' do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  end

  after "deploy:finalize_update", "uploads:symlink"
  after "deploy", "deploy:cleanup"
  after "deploy:migrations", "deploy:cleanup"
  after "deploy:symlink", "deploy:update_crontab"

end