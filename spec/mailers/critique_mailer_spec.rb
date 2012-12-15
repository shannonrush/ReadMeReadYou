require "spec_helper"

describe CritiqueMailer do
  let(:author){FactoryGirl.create(:user)}
  before do
    User.any_instance.stub(:send_welcome)
  end
  
  let(:submission){FactoryGirl.create(:submission,:user => user)}
  let(:critiquer){FactoryGirl.create(:user)}
  before do
    User.any_instance.stub(:send_welcome)
  end
  let(:critique){FactoryGirl.create(:critique,:user => critiquer)}

  before do
    Critique.any_instance.stub(:send_notification)
    Critique.any_instance.stub(:alert_for_new_critique)
  end
  describe "#notification(critique)" do
    it 'should send an email with the correct subject and body content to the critique submission author' do
      ActionMailer::Base.deliveries = []
      CritiqueMailer.notification(critique).deliver
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match critique.submission.user.email
      mail['subject'].to_s.should match "#{critique.submission.title} has a new critique!"
      mail.body.to_s.should include("Hi #{critique.submission.user.first}!")
    end
  end

  describe '#report_abuse(critique)' do
    it 'should send an email with the correct subject and content to support' do
      ActionMailer::Base.deliveries = []
      CritiqueMailer.report_abuse(critique).deliver
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match "support@readmereadyou.com"
      mail['subject'].to_s.should match "Abusive critique reported"
      mail.body.to_s.should include("Critique Reported")
    end
  end

end
