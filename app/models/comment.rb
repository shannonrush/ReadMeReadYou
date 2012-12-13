class Comment < ActiveRecord::Base
  belongs_to :critique
  belongs_to :user

  validates_presence_of :content, :critique

  attr_accessible :content, :critique_id, :user_id

  after_create :generate_alerts

  protected

  def generate_alerts
    # alert critiquer
    title = self.critique.submission.title_with_chapters
    link = "/critiques/#{self.critique.id}"
    id = self.critique.user.id
    Alert.generate(id, "Your critique on #{title} has a new comment",link)
    # alert other commenters
    users = self.critique.comments.collect {|c| c.user}.uniq.reject{|u|u==self.critique.user}
    users.each {|u| Alert.generate(u.id, "The critique on #{title} has a new comment",link)}
  end
end
