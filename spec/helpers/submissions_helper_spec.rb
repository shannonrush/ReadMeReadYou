require 'spec_helper'

describe SubmissionsHelper do
  let (:submission) {FactoryGirl.create(:submission)}
  let (:crit_user) {FactoryGirl.create(:user, email:"crit@rmry.com")}
  
  describe '#has_notes?' do
    it 'returns true if submission has notes' do
      helper.has_notes?(submission).should be_true
    end
    it 'returns false is submission does not have notes' do
      submission.update_attribute(:notes,"")
      helper.has_notes?(submission).should be_false
    end
  end
  describe '#has_chapters?' do
    it 'returns true if submission has chapters' do
      chapter = FactoryGirl.create(:chapter)
      submission.chapters << chapter
      submission.reload
      helper.has_chapters?(submission).should be_true
    end
    it 'returns false if submission has no chapters' do
      helper.has_chapters?(submission).should be_false
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
end
