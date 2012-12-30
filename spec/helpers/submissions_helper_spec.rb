require 'spec_helper'

describe SubmissionsHelper do
  let (:submission) {FactoryGirl.create(:submission)}
  let (:crit_user) {FactoryGirl.create(:user, email:"crit@rmry.com")}
  
  describe '#has_other_chapters?(submission)' do
    before(:each) do
      Chapter.create(submission:submission,name:"1")
      submission.update_attribute(:activated_at,Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:submission)}
    end

    it 'returns true if other submissions with title for user that have chapters and are not in queue' do
      Submission.active.should_not include(submission)
      sub2 = FactoryGirl.create(:submission,user:submission.user,title:submission.title) 
      Chapter.create(submission:sub2,name:"2")
      Chapter.create(submission:sub2,name:"3")
      Submission.not_in_queue.should include(sub2)
      helper.has_other_chapters?(submission).should be_true
    end

    it 'returns false if other submissions with title for user that have chapters and are in queue' do
      sub2 = FactoryGirl.create(:submission,user:submission.user,title:submission.title,queued:true)      
      Chapter.create(submission:sub2,name:"2")
      Chapter.create(submission:sub2,name:"3")
      Submission.in_queue.should include(sub2)
      helper.has_other_chapters?(submission).should be_false
      
    end
    
    it 'returns false if other submissions with title with chapters for another user' do
      sub2 = FactoryGirl.create(:submission,user:FactoryGirl.create(:user),title:submission.title)
      Chapter.create(submission:sub2,name:"2")
      Chapter.create(submission:sub2,name:"3")
      helper.has_other_chapters?(submission).should be_false
    end
  
    it 'returns false if other submissions with title for user with no chapters' do
      sub2 = FactoryGirl.create(:submission,user:submission.user,title:submission.title)
      helper.has_other_chapters?(submission).should be_false
    end

    it 'returns false if other submission with chapters for user with another title' do
      sub2 = FactoryGirl.create(:submission,user:submission.user,title:"different title")
      Chapter.create(submission:sub2,name:"2")
      Chapter.create(submission:sub2,name:"3")
      helper.has_other_chapters?(submission).should be_false
    end
  end

  describe '#other_chapters' do
    before(:each) do
      Chapter.create(submission:submission,name:"1")
      submission.update_attribute(:activated_at,Time.zone.now-8.days)
      5.times {FactoryGirl.create(:critique,submission:submission)}
    end
    it 'returns the other chapters for submissions with same title for user that are not queued' do
      submission.chapters.count.should eql(1)
      sub2 = FactoryGirl.create(:submission,user:submission.user,title:submission.title) 
      ch2 = Chapter.create(submission:sub2,name:"2")
      ch3 = Chapter.create(submission:sub2,name:"3")
      helper.other_chapters(submission).should eql([ch2,ch3])
    end
    
  end

  describe '#has_chapters?' do
    it 'returns true if submission has chapters' do
      chapter = FactoryGirl.create(:chapter,submission:submission)
      submission.chapters.reload
      helper.has_chapters?(submission).should be_true
    end
    it 'returns false if submission has no chapters' do
      helper.has_chapters?(submission).should be_false
    end
  end
  describe '#has_notes?' do
    it 'returns true if submission has notes' do
      helper.has_notes?(submission).should be_true
    end
    it 'returns false is submission does not have notes' do
      submission.update_attribute(:notes,"")
      helper.has_notes?(submission).should be_false
    end
  end
  describe '#has_critiques?(submission)' do
    it 'returns  false if submission has no critiques' do
      helper.has_critiques?(submission).should be_false
    end
    it 'returns true if submission has critiques' do
      critique = Critique.create(submission_id:submission.id,user_id:crit_user.id,content:"critique")
      submission.reload
      helper.has_critiques?(submission).should be_true
    end
  end

  describe '#word_count(submission)' do
    it 'returns the word count of processed' do
      submission.processed = "one two three"
      helper.word_count(submission).should eql(3)
    end
  end

  describe '#sentence_count(submission)' do
    it 'returns the sentence count of processed' do
      submission.processed = "This is one sentence? This is another sentence! This is a third sentence. This is a fourth...This is a fifth"
      helper.sentence_count(submission).should eql(5)
    end
  end

  describe '#average_sentence_length(submission)' do
    it 'returns the average sentence length of processed' do
      submission.processed = "This has four words. This sentence has five words. This is a sentence with six."
      helper.average_sentence_length(submission).should eql(5)
    end
  end

  describe '#lexical_density(submission)' do
    it 'returns the number of unique words divided by the number of words in processed' do
      submission.processed = "These words repeat words these"
      helper.lexical_density(submission).should eql(60)
    end
  end

  describe '#gunning_fog(submission)' do
  end
end
