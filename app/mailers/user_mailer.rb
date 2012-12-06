class UserMailer < ActionMailer::Base
  default from: "\"RMRY\"<support@readmereadyou.com>"

  def welcome(user)
    mail(
      to:user.email,
      subject:"Welcome!"
    )
  end
end
