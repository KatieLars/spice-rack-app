class Recipe < ActiveRecord::Base
  has_many :recipe_spice_flavors
  has_many :flavors, through: :recipe_spice_flavors
  has_many :spices, through: :recipe_spice_flavors
  belongs_to :user
  validates :name, presence: true

  def spice_ids=(spice_ids) #returns a single object or array of objects
    spices.clear
    spice_ids.each do |spice_id|
      spices << Spice.find_by_id(spice_id)
      save
    end
  end

  def spice=(spice)
    spices << Spice.create(spice)
  end

  def update_spice_user_id
    self.spices.each {|spice| spice.update(user_id: self.user_id)}
  end

  def slug
    name.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
      recipe_name = slug.gsub("-", " ").upcase
      self.all.detect {|recipe| recipe.name.upcase == recipe_name}
  end

end

@luke
