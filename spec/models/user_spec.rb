require 'spec_helper'

describe User do
  let (:user) {FactoryGirl.create(:user)}

  describe 'validations' do

    it 'requires first on update to be valid' do
      user.should be_valid
      user.update_attribute(:first,nil)
      user.should_not be_valid
    end

    it 'requires last on update to be valid' do
      user.should be_valid
      user.update_attribute(:last,nil)
      user.should_not be_valid
    end

    it 'requires email on update to be valid' do
      user.should be_valid
      user.update_attribute(:email,nil)
      user.should_not be_valid
    end
  end

  describe 'after_create :send_welcome' do
    it 'sends welcome to user after create' do
      ActionMailer::Base.deliveries = []
      user = FactoryGirl.create(:user)
      ActionMailer::Base.deliveries.count.should eql(1)
      mail = ActionMailer::Base.deliveries.first
      mail['to'].to_s.should match user.email
    end
  end

  describe '#full_name' do
    it 'returns first + last name if first and last' do
      user.first.should_not be_nil
      user.last.should_not be_nil
      user.full_name.should match "#{user.first} #{user.last}"
    end
    it 'returns unknown if first is nil' do
      user.update_attribute(:first,nil)
      user.full_name.should match "Unknown"
    end
    it 'returns unknown if last is nil' do
      user.update_attribute(:first,nil)
      user.full_name.should match "Unknown"
    end
  end

  describe '#needs_profile_update?' do
    it 'returns true if first is nil' do
      user.update_attribute(:first,nil)
      user.needs_profile_update?.should be_true
    end

    it 'returns true if last is nil' do
      user.update_attribute(:last,nil)
      user.needs_profile_update?.should be_true
    end

    it 'returns true if email is nil' do
      user.update_attribute(:email,nil)
      user.needs_profile_update?.should be_true
    end

    it 'returns false if first last and email are present' do
      user.needs_profile_update?.should be_false
    end
  end
end
