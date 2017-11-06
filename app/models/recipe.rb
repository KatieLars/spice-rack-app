class Recipe < ActiveRecord::Base
  has_many :flavors, through: :recipe_spice_flavor
  has_many :spices, through: :recipe_spice_flavor
  belongs_to :user
  has_many :recipe_spice_flavors

end
