class Recipe < ActiveRecord::Base
  has_many :recipe_spice_flavors
  has_many :flavors, through: :recipe_spice_flavors
  has_many :spices, through: :recipe_spice_flavors
  belongs_to :user

  def slug
    name.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
      recipe_name = slug.gsub("-", " ").upcase
      self.all.detect {|recipe| recipe.name.upcase == recipe_name}
  end

end
