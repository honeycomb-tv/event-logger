#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'resque/server'

# Set the RESQUECONFIG env variable if you've a `resque.rb` or similar
# config file you want loaded on boot.
if ENV['RESQUECONFIG'] && ::File.exists?(::File.expand_path(ENV['RESQUECONFIG']))
  load ::File.expand_path(ENV['RESQUECONFIG'])
end

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

AUTH_PASSWORD = "dingbat3"
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

use Rack::ShowExceptions
run Resque::Server.new