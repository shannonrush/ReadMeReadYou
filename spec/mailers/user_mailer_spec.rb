require "spec_helper"

describe UserMailer do
  let(:user){FactoryGirl.create(:user)}
  before do
    User.any_instance.stub(:send_welcome)
  end
  describe '#welcome' do
    it 'should send an email with the correct subject and body content to the new user' do
      ActionMailer::Base.deliveries = []
      UserMailer.welcome(user).deliver
      ActionMailer::Base.deliveries.count.should eq(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match user.email
      mail['subject'].to_s.should match "Welcome!"
    end
  end
end
