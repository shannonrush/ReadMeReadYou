class User < ActiveRecord::Base
  has_many :submissions
  has_many :critiques
  
  attr_accessible :bio, :email, :first, :last
end
