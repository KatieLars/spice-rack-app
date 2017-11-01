class Spice < ActiveRecord::Base
  belongs_to :flavor
  has_many :recipes, through: :recipe_spice_flavor
  belongs_to :user
  validates_presence_of :name

  def slug
    username.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    user_name = slug.gsub("-", " ").upcase
    self.all.detect {|user| user.username.upcase == user_name}
  end
end
