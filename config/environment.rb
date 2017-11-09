

require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "db/development.sqlite"
)

require_all 'app'
require_all 'lib'
