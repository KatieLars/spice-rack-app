class RecipeSpiceFlavor < ActiveRecord::Base
  belongs_to :flavor
  belongs_to :spice
  belongs_to :recipe
  belongs_to :user

end
