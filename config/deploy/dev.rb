set :deploy_to, "/var/www/vhosts/#{application}.koredesign.com"
set :user, "deploy"
set :bundle_command, "bundle"
set :branch, "master"
server "codero.freshlimestudio.com", :app, :web, :db, :primary => true

