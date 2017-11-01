require_relative './config/environment'

if ActiveRecord::Migrator.needs_migration?
  raise "Migrations pending. Run 'rake db:migrate'"
end

use Rack::MethodOverride
run AppController
