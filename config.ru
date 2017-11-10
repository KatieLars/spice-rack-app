
require './config/environment'

if ActiveRecord::Migrator.needs_migration?
  raise "Migrations pending. Run 'rake db:migrate'"
end

use Rack::MethodOverride
use SpiceController
use RecipeController

run AppController
