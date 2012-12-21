require 'spec_helper'

describe UsersHelper do
  let (:message) {FactoryGirl.create(:message)}

  describe '#genres_written(user)' do
    it 'returns genre with no commas if 1 genre submitted' do
      submission = FactoryGirl.create(:submission,genre:"Fantasy")
      helper.genres_written(submission.user).should match "Fantasy"
    end

    it 'returns a comma delimited list of genres submitted if more than 1' do
      submission = FactoryGirl.create(:submission,genre:"Fantasy")
      sub2 = FactoryGirl.create(:submission,user:submission.user,genre:"Horror")
      submission.user.submissions.reload
      helper.genres_written(submission.user).should match "Fantasy, Horror"
    end

    it 'returns just one genre if two submissions made with same genre' do
      submission = FactoryGirl.create(:submission,genre:"Fantasy")
      sub2 = FactoryGirl.create(:submission,genre:"Fantasy")
      helper.genres_written(submission.user).should match "Fantasy"
    end

    it 'returns None Yet if no submissions' do
      user = FactoryGirl.create(:user)
      helper.genres_written(user).should match "None Yet"
    end
  end

  describe '#average_rating(user)' do
    it 'returns N/A if user has made no critiques' do
      user = FactoryGirl.create(:user)
      helper.average_rating(user).should match "N/A"
    end

    it 'returns N/A if user has made a critique that has not been rated' do
      c = FactoryGirl.create(:critique)
      c.rating.should be_nil
      helper.average_rating(c.user).should match "N/A"
    end

    it 'returns critique rating if 1 critique' do
      c = FactoryGirl.create(:critique,rating:10)
      helper.average_rating(c.user).should eql(10)
    end

    it 'returns sum divided by length if more than 1 critique' do
      c = FactoryGirl.create(:critique,rating:10)
      c2 = FactoryGirl.create(:critique,user:c.user,rating:0)
      helper.average_rating(c.user).should eql(5)
    end

    it 'disregards nil ratings when calculating average' do
      c = FactoryGirl.create(:critique,rating:10)
      c2 = FactoryGirl.create(:critique,user:c.user)
      c2.rating.should be_nil
      helper.average_rating(c.user).should eql(10)
    end
  end

  describe '#number_rated(user)' do
    it 'returns the count of user critiques where rating is not nil' do
      c = FactoryGirl.create(:critique,rating:10)
      c2 = FactoryGirl.create(:critique,user:c.user)
      c2.rating.should be_nil
      helper.number_rated(c.user).should eql(1) 
    end
  end

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
