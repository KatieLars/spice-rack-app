class User < ActiveRecord::Base
  has_many :flavors
  has_many :recipes
  has_many :recipe_spice_flavors
  has_many :spices
  validates_presence_of :username, :password, :email
  validates :username, uniqueness: true
  validates :email, uniqueness: true
  has_secure_password

  def slug
      username.downcase.gsub(" ", "-")
    end

    def self.find_by_slug(slug)
      user_name = slug.gsub("-", " ").upcase
      self.all.detect {|user| user.username.upcase == user_name}
    end


end
