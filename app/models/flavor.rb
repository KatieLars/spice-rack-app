class Flavor < ActiveRecord::Base
  has_many :spices
  has_many :recipes, through: :recipe_spice_flavor
  has_many :users, through: :recipe_spice_flavor
  has_many :recipe_spice_flavors
  validates_presence_of :name
end
