
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.install

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/development.sqlite"
)

require_all 'app'
require_all 'lib'
