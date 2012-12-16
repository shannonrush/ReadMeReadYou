class Critique < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  belongs_to :submission

  attr_accessible :created_at, :content, :rating, :submission, :submission_id, :user, :user_id

  validates_presence_of :content, :message => "file must be chosen"

  after_create :send_notification, :alert_for_new_critique
  after_update :report_if_abusive_rating, :alert_for_rating

  default_scope order('created_at DESC')

  def self.ordered_by(critiques, order_by)
    if order_by == "submission_title"
      return critiques.sort {|a,b| a.submission.title <=> b.submission.title}
    elsif order_by == "critiquer"
      return critiques.sort {|a,b| a.user.last <=> b.user.last}
    elsif order_by == "rating"
      return critiques.sort_by {|c| c.rating.to_i}
    else order_by == "created_at"
      return critiques.sort_by{|c|c.created_at}
    end
  end

  protected

  def alert_for_new_critique
    # alert submission author of critique
    Alert.generate(self.submission.user.id,"#{self.submission.title_with_chapters} has a new critique!","/critiques/#{self.id}")
  end

  def alert_for_rating
    # alert critiquer of rating 
    if @changed_attributes.keys.include?("rating") && self.rating.present?
      Alert.generate(self.user.id,"Your critique for #{self.submission.title_with_chapters} has been rated","/critiques/#{self.id}")
    end
  end

  def send_notification
    CritiqueMailer.notification(self).deliver
  end

  def report_if_abusive_rating
    if self.rating == -1
      CritiqueMailer.report_abuse(self).deliver
    end
  end
end
