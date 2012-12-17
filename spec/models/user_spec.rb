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

  describe 'scope :has_queued_submissions' do
    it 'includes user if any submissions in queue' do
      new_submission = FactoryGirl.create(:submission,user:user,queued:true)
      Submission.in_queue.should include(new_submission)
      User.has_queued_submissions.should include(user)
    end
    it 'does not include user if does not have any submissions in queue)' do
      new_submission = FactoryGirl.create(:submission,user:user)
      Submission.in_queue.should_not include(new_submission)
      User.has_queued_submissions.should_not include(user)
    end
  end

  describe 'scope :without_active_submission' do
    it 'includes user who does not have any submissions' do
      user.submissions.count.should eql(0)
      User.without_active_submission.should include(user)
    end
    
    it 'includes user who has a submission that does not need time or critiques' do
      submission = FactoryGirl.create(:submission,user:user,created_at:Time.zone.now-8.days) 
      5.times {FactoryGirl.create(:critique,submission:submission)}
      user.submissions.should include(submission)
      Submission.inactive.should include(submission)
      User.without_active_submission.should include(user)
    end

    it 'excludes user who has a submission that needs time and does not need critiques' do
      submission = FactoryGirl.create(:submission,user:user,created_at:Time.zone.now-8.days) 
      user.submissions.should include(submission)
      Submission.inactive.should_not include(submission)
      User.without_active_submission.should_not include(user)
    end

    it 'excludes user who has submission that does not need time and needs critiques' do
      submission = FactoryGirl.create(:submission,user:user,created_at:Time.zone.now-8.days) 
      user.submissions.should include(submission)
      Submission.inactive.should_not include(submission)
      User.without_active_submission.should_not include(user)
    end
  end

  describe 'scope :needs_submission_activated' do
    it 'includes user with a submission in queue and an inactive submission' do
      submission1 = FactoryGirl.create(:submission,user:user,created_at:Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:submission1)}
      Submission.inactive.should include(submission1)
      submission2 = FactoryGirl.create(:submission,user:user,queued:true)
      Submission.in_queue.should include(submission2)
      User.has_queued_submissions.should include(user)
      User.without_active_submission.should include(user)
      User.needs_submission_activated.should include(user)
    end

    it 'excludes user with no submissions' do
      user.submissions.count.should eql(0)
      User.needs_submission_activated.should_not include(user)
    end

    it 'excludes user with inactive submission and no submission in queue' do
      submission1 = FactoryGirl.create(:submission,user:user,created_at:Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:submission1)}
      Submission.inactive.should include(submission1)
      User.without_active_submission.should include(user)
      User.has_queued_submissions.should_not include(user)
      User.needs_submission_activated.should_not include(user)
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
