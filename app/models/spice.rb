class Spice < ActiveRecord::Base
  belongs_to :flavor
  has_many :recipes, through: :recipe_spice_flavor
  belongs_to :user
  validates_presence_of :name
end
