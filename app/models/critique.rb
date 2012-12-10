class Critique < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  belongs_to :submission

  attr_accessible :content, :rating, :submission_id, :user_id

  validates_presence_of :content, :message => "file must be chosen"

  validates_presence_of :rating, :only => :update

  after_create :send_notification
  after_update :report_if_abusive_rating

  protected

  def send_notification
    CritiqueMailer.notification(self).deliver
  end

  def report_if_abusive_rating
    if self.rating == -1
      CritiqueMailer.report_abuse(self).deliver
    end
  end
end
