class Critique < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  belongs_to :submission

  attr_accessible :content, :rating, :submission_id, :user_id

  validates_presence_of :content, :message => "file must be chosen"

  validates_presence_of :rating, :only => :update

  after_create :send_notification

  protected

  def send_notification
    CritiqueMailer.notification(self).deliver
  end
end
