class User < ActiveRecord::Base
  has_many :recipe_spice_flavors
  has_many :spices
  has_many :flavors, through: :spices
  has_many :recipes
  has_many :spices

  has_secure_password
  validates :username, :email, presence: true
  validates :email, :username, uniqueness: true

  def slug
    username.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    user_name = slug.gsub("-", " ").upcase
    self.all.detect {|user| user.username.upcase == user_name}
  end


end
