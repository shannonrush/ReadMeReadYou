class CommentMailer < ActionMailer::Base
  default from: "\"RMRY\"<support@readmereadyou.com>"

  def notification(comment, user)
    @comment = comment
    @user = user
    mail(
      to:user.email,
      subject:"Critique for #{comment.critique.submission.title} has a new comment")
  end
end
