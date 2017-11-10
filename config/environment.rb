

require 'bundler/setup'
Bundler.require

#db = URI.parse('postgres://ahddyelhqcrghk:a9890d2747b5a132ba2f80cf891b6e851f6c0113d9f24e65abdf0ad998940b73@ec2-50-17-235-5.compute-1.amazonaws.com:5432/d3n9tu2hps02jt')

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => DATABASE_URL
)

require_all 'app'
require_all 'lib'
