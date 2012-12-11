class User < ActiveRecord::Base
  
  # paperclip
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => '/assets/missing_avatar.png'
  
  # devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :submissions
  has_many :critiques
  has_many :alerts

  validates_presence_of [:first, :last], :on => :update, :message => "name can't be blank"

  attr_accessible :avatar, :bio, :email, :first, :last, :password, :password_confirmation, :remember_me

  after_create :send_welcome

  def full_name
    self.first+" "+self.last
  end

  protected

  def send_welcome
    UserMailer.welcome(self).deliver
  end
end
