require "spec_helper"

describe CommentMailer do
  describe '#notification(comment,user)' do
    it 'sends an email with notification subject and body content' do
      comment = FactoryGirl.create(:comment)
      ActionMailer::Base.deliveries = []
      CommentMailer.notification(comment, comment.critique.user).deliver
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match comment.critique.user.email
      title = comment.critique.submission.title
      mail['subject'].to_s.should match "Critique for #{title} has a new comment"
      mail.body.to_s.should include("the critique for #{title}")
    end
  end
end
