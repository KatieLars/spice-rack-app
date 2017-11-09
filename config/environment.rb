

require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "./db/spice_rack.db"
)

require_all 'app'
require_all 'lib'
