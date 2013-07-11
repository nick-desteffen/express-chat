require "capistrano/node-deploy"

set :application, "express-chat"
set :repository,  "git@github.com:nick-desteffen/express-chat.git"
set :user, "nickd"
set :scm, :git
set :deploy_to, "/var/www/apps/express-chat"
set :use_sudo, false
set :normalize_asset_timestamps, false

role :app, "chat.nickdesteffen.com"

default_run_options[:pty] = true
