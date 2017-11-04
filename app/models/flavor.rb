class Flavor < ActiveRecord::Base
  has_many :spices
  has_many :recipes, through: :recipe_spice_flavor
  has_many :users, through: :recipe_spice_flavor
  validates_presence_of :name
end
