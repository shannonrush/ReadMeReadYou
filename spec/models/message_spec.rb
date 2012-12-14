require 'spec_helper'

describe Message do
  let(:message) {FactoryGirl.create(:message)}

  describe 'validations' do
    it 'should require to to be valid' do
      message.should be_valid
      message.update_attribute(:to,nil)
      message.should_not be_valid
    end

    it 'should require from to be valid' do
      message.should be_valid
      message.update_attribute(:from,nil)
      message.should_not be_valid
    end
    it 'should require subject to be valid' do
      message.should be_valid
      message.update_attribute(:subject,nil)
      message.should_not be_valid
    end
    it 'should require message to be valid' do
      message.should be_valid
      message.update_attribute(:message,nil)
      message.should_not be_valid
    end
  end

  describe 'after_create :send_notification' do
    it 'should should send one email to message receiver' do
      ActionMailer::Base.deliveries = []
      to = FactoryGirl.create(:user_no_after_create)
      from = FactoryGirl.create(:user_no_after_create)
      new_message = FactoryGirl.create(:message,to:to,from:from)
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match new_message.to.email
    end
  end

  describe 'scope :undeleted' do
    it 'should include messages where deleted is not true' do
      message.deleted.should_not be_true
      Message.undeleted.should include(message)
    end
    it 'should not include messages where deleted is true' do
      message.update_attribute(:deleted,true)
      message.deleted.should be_true
      Message.undeleted.should_not include(message)
    end
  end

  describe 'scope :to_user' do
    it 'should include messages to user' do
      user = FactoryGirl.create(:user)
      message.update_attribute(:to,user)
      Message.to_user(user).should include(message)
    end

    it 'should not include messages not to user' do
      user = FactoryGirl.create(:user)
      message.to.should_not eql(user)
      Message.to_user(user).should_not include(message)
    end
  end

  describe 'scope :from_user' do
    it 'should include messages from user' do
      user = FactoryGirl.create(:user)
      message.update_attribute(:from,user)
      Message.from_user(user).should include(message)
    end

    it 'should not include messages not to user' do
      user = FactoryGirl.create(:user)
      message.from.should_not eql(user)
      Message.from_user(user).should_not include(message)
    end
  end

  describe 'default_scope' do
    it 'should return sorted by created_at with latest first' do
      message1 = FactoryGirl.create(:message,created_at:"Jaanuary 15, 1974")
      message2 = FactoryGirl.create(:message,created_at:"January 1, 1974")
      Message.all.should eql([message1,message2])
    end
  end
end
