class Comment < ActiveRecord::Base
  belongs_to :critique
  belongs_to :user

  validates_presence_of :content, :critique

  attr_accessible :content, :critique, :critique_id, :user, :user_id

  after_create :alerts_for_new_comment, :emails_for_new_comment

  protected

  def emails_for_new_comment
    email_critiquer unless self.user == self.critique.user
    email_other_commenters
  end

  def email_critiquer
    CommentMailer.notification(self,self.critique.user).deliver
  end

  def email_other_commenters
    other_commenters = self.other_commenters
    other_commenters.each do |u|
      CommentMailer.notification(self,u).deliver
    end
  end

  def alerts_for_new_comment
    title = self.critique.submission.title_with_chapters
    link = "/critiques/#{self.critique.id}"
    alert_critiquer(title, link) unless self.user == self.critique.user
    alert_other_commenters(title, link)
  end

  def alert_critiquer(title, link)
    message = "Your critique on #{title} has a new comment"
    Alert.generate(self.critique.user.id,message,link)
  end

  def alert_other_commenters(title, link)
    other_commenters = self.other_commenters
    message = "The critique on #{title} has a new comment"
    other_commenters.each do |o|
      Alert.generate(o.id,message,link)
    end
  end

  def other_commenters
    # users who have commented on critique besides the critiquer and the commenter
    users = self.critique.comments.collect {|c| c.user}
    [self.critique.user, self.user].each {|u| users.delete(u)}
    return users
  end

end
