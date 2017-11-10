

require 'bundler/setup'
Bundler.require

db = URI.parse('postgres://localhost/spice_rack')

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "/Applications/Postgres.app/Contents/Versions/9.6/bin/psql" -p5432 -d "spice_rack"
)

require_all 'app'
require_all 'lib'
