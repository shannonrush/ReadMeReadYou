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

  def report_abuse(critique)
    @critique = critique
    mail(
      to:"support@readmereadyou.com",
      subject:"Abusive critique reported"
    )
  end
end
