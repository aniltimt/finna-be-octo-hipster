set :deploy_to, "/var/www/vhosts/ctiplastic.com/rails"
set :user, "cti_live"
set :bundle_command, "/usr/local/bin/bundle"
set :branch, "master"
server "proto2.korehost.net", :app, :web, :db, :primary => true
