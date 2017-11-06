class Recipe < ActiveRecord::Base
  has_many :recipe_spice_flavors
  has_many :flavors, through: :recipe_spice_flavors
  has_many :spices, through: :recipe_spice_flavors
  belongs_to :user

end
