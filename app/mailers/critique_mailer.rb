class CritiqueMailer < ActionMailer::Base
  default from: "\"RMRY\"<support@readmereadyou.com>"

  def notification(critique)
    @critique = critique
    @author = critique.submission.user
    mail(
      to:@author.email,
      subject:"#{critique.submission.title} has a new critique!"
    )
  end
end
