
require 'bundler/setup'
Bundler.require(File.read("/Users/kmlarson/spice-rack-app/Gemfile"))

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/development.sqlite"
)

require_all 'app'
require_all 'lib'
