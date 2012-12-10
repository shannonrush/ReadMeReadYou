require "spec_helper"

describe CritiqueMailer do
  let(:author){FactoryGirl.create(:user_no_after_create, :email => "author@rmry.com")}
  let(:submission){FactoryGirl.create(:submission,:user => user)}
  let(:critiquer){FactoryGirl.create(:user_no_after_create, :email => "critiquer@rmry.com")}
  let(:critique){FactoryGirl.create(:critique_no_after_create,:user => critiquer)}

  describe "#notification" do
    it 'should send an email with the correct subject and body content to the critique submission author' do
      ActionMailer::Base.deliveries = []
      CritiqueMailer.notification(critique).deliver
      ActionMailer::Base.deliveries.count.should eq(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match critique.submission.user.email
      mail['subject'].to_s.should match "#{critique.submission.title} has a new critique!"
      mail.body.to_s.should include("Hi #{critique.submission.user.first}!")
    end
  end

end
