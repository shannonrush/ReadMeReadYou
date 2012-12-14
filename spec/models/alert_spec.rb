require 'spec_helper'

describe Alert do
  let (:user) {FactoryGirl.create(:user,email:"rn@rmry.com")}
  let (:uncleared_alert) {FactoryGirl.create(:alert)}
  let (:alert) {FactoryGirl.create(:alert,cleared:true,user:user)}

  describe 'scope :uncleared' do
    it 'should include alerts where cleared true' do
      Alert.uncleared.should include(uncleared_alert)  
    end
    it 'should exclude alerts where cleared not true' do
      Alert.uncleared.should_not include(alert)  
    end
  end

  describe 'scope :for_user' do
    it 'should include alerts for user' do
      Alert.for_user(user).should include(alert)
    end
    it 'should exclude alerts not for user' do
      Alert.for_user(user).should_not include(uncleared_alert)
    end
  end

  describe 'default_scope' do
    it 'should be sorted by created_at with earliest first' do
      alert.created_at = "January 1, 1974"
      uncleared_alert.created_at = "January 15, 1974"
      Alert.all.first.should eql(alert)
    end
  end

  describe '#self.generate(user_id, message, link="")' do
    it 'should created an Alert with user id, message and link' do
      Alert.count.should eql(0)
      Alert.generate(user.id, "Alert message", "/critiques/2")
      Alert.count.should eql(1)
      alert = Alert.first
      alert.user_id.should eql(user.id)
      alert.message.should eql("Alert message")
      alert.link.should eql("/critiques/2")
    end
  end

end
