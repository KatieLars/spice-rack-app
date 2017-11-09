require './config/environment'

$:<<File.dirname("/Users/kmlarson/spice-rack-app")
require "./app/models/site_generator"
run SiteGenerator.new

#if ActiveRecord::Migrator.needs_migration?
#  raise "Migrations pending. Run 'rake db:migrate'"
#end

#use Rack::MethodOverride
#use SpiceController
#use RecipeController

#run AppController
