class Recipe < ActiveRecord::Base
  has_many :flavors, through: :recipe_spice_flavor
  has_many :spices, through: :recipe_spice_flavor
  belongs_to :user

end
