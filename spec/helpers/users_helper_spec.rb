require 'spec_helper'

describe UsersHelper do
  let (:message) {FactoryGirl.create(:message)}
  
  describe '#new_message_visibility(message)' do
    it 'should return hidden if message has no errors' do
      helper.new_message_visibility(message).should eql("hidden")
    end
    it 'should return shown if message has errors' do
      errors = {:subject=>["can't be blank"]}  
      errors.each { |attr, msg| message.errors.add(attr, msg) }
      helper.new_message_visibility(message).should eql("shown")
    end
  end

  describe '#date_for_inbox(message)' do
    it 'should return message created at as mm/dd/yy' do
      message.created_at = "January 15, 1974 at 12:00pm"
      helper.date_for_inbox(message).should eql("01/15/74")
    end
  end

  describe '#subject_link_weight(message)' do
    it 'should return empty string if message read' do
      message.read = true
      helper.subject_link_weight(message).should eql("")
    end
    it 'should return bolder_link if message not read' do
      helper.subject_link_weight(message).should eql("bolder_link")
    end
  end

  describe '#submission_status' do
    it 'returns active if submission active' do
      submission = FactoryGirl.create(:submission)
      helper.submission_status(submission).should match "active"
    end

    it 'returns Queued # with index of queue + 1 if in queue' do
      submission = FactoryGirl.create(:submission)
      queued = FactoryGirl.create(:submission,user:submission.user)
      submission.user.submissions.reload
      Submission.in_queue.should include(queued)
      helper.submission_status(queued).should match "Queued #1"
    end
    
    it 'returns Queued #1 for earliest and Queued #2 for next in queue' do
      submission = FactoryGirl.create(:submission)
      queued = FactoryGirl.create(:submission,user:submission.user)
      queued2 = FactoryGirl.create(:submission,user:submission.user)
      submission.user.submissions.reload
      helper.submission_status(queued).should match "Queued #1"
      helper.submission_status(queued2).should match "Queued #2"
       
    end

    it 'returns critiqued if submission not in queue and not active' do
      submission = FactoryGirl.create(:submission,created_at:Time.zone.now - 8.days)
      5.times {FactoryGirl.create(:critique,submission:submission)}
      Submission.inactive.should include(submission)
      helper.submission_status(submission).should match "critiqued"
    end
  end
end
