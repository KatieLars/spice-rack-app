class Flavor < ActiveRecord::Base
  has_many :spices
  has_many :recipes, through: :recipe_spice_flavor
  belongs_to :user
  validates_presence_of :name
end
