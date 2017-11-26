class Spice < ActiveRecord::Base
  belongs_to :flavor
  has_many :recipe_spice_flavors
  has_many :recipes, through: :recipe_spice_flavors
  belongs_to :user
  validates :name, presence: true
  validates :name, uniqueness: {scope: :user}

  def recipe_ids=(recipe_ids) 
    recipes.clear
    recipe_ids.each do |recipe_id|
      recipes << Recipe.find_by_id(recipe_id)
      save
    end
  end

  def recipe=(recipe)
    recipes << Recipe.create(recipe)
  end

  def update_recipe_user_id
    self.recipes.each {|recipe| recipe.update(user_id: self.user_id)}
  end

  def slug
    name.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
      spice_name = slug.gsub("-", " ").upcase
      self.all.detect {|spice| spice.name.upcase == spice_name}
  end
end
