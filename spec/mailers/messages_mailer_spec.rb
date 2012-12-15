require "spec_helper"

describe MessagesMailer do
  describe '#notification(message)' do
    it 'should send an email with the correct subject and body content to message receiver' do
      User.any_instance.stub(:send_welcome)
      to = FactoryGirl.create(:user)
      from = FactoryGirl.create(:user)
      Message.any_instance.stub(:notification)
      message = FactoryGirl.create(:message)
      ActionMailer::Base.deliveries = []
      MessagesMailer.notification(message).deliver
      ActionMailer::Base.deliveries.count.should eq(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match message.to.email
      mail['subject'].to_s.should match "New RMRY Message from #{message.from.full_name}"
      mail.body.to_s.should include("Subject: #{message.subject}")      
    end
  end
end
