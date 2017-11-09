class Spice < ActiveRecord::Base
  belongs_to :flavor
  has_many :recipe_spice_flavors
  has_many :recipes, through: :recipe_spice_flavors
  belongs_to :user
  validates_presence_of :name

  def slug
    name.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
      spice_name = slug.gsub("-", " ").upcase
      self.all.detect {|spice| spice.name.upcase == spice_name}
  end
end
