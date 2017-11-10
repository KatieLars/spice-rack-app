

require 'bundler/setup'
Bundler.require

db = URI.parse('postgres://localhost/spice_rack')
ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => db.path[1..-1]
)

require_all 'app'
require_all 'lib'
