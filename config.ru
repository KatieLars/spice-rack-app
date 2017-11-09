require_relative './config/environment'

$:<<File.dirname("/Users/kmlarson/spice-rack-app")
#require_all "./app/controllers"

if ActiveRecord::Migrator.needs_migration?
  raise "Migrations pending. Run 'rake db:migrate'"
end

use Rack::MethodOverride
use SpiceController
use RecipeController

run AppController
