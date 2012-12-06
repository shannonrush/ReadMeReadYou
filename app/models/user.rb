class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :submissions
  has_many :critiques
  
  attr_accessible :bio, :email, :first, :last, :password, :password_confirmation, :remember_me

  after_create :send_welcome

  protected

  def send_welcome
    UserMailer.welcome(self).deliver
  end
end
