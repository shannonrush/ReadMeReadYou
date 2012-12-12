class MessagesMailer < ActionMailer::Base
  default from: "\"RMRY\"<support@readmereadyou.com>"

  def notification(message)
    @message = message
    mail(
      to:@message.to.email,
      subject:"New RMRY Message from #{@message.from.full_name}"
    )
  end
end
