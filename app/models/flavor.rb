class Flavor < ActiveRecord::Base
  has_many :recipe_spice_flavors
  has_many :spices
  has_many :recipes, through: :recipe_spice_flavors
  has_many :users, through: :recipe_spice_flavors
  validates_presence_of :name
end
