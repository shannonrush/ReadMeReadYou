class User < ActiveRecord::Base
  
  # paperclip
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => '/assets/missing_avatar.png'
  
  # devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :submissions
  has_many :critiques
  has_many :alerts
  has_many :messages

  validates_presence_of [:first, :last], :on => :update, :message => "name can't be blank"
  validates_presence_of :email, :on => :update

  attr_accessible :avatar, :bio, :email, :first, :last, :password, :password_confirmation, :remember_me

  after_create :send_welcome

  def full_name
    if self.first && self.last
      self.first+" "+self.last
    else
      "Unknown"
    end
  end

  def needs_profile_update?
    self.first.nil? || self.last.nil? || self.email.nil?
  end

  protected

  def send_welcome
    UserMailer.welcome(self).deliver
  end
end
