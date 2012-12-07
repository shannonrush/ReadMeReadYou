require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SubmissionsHelper. For example:
#
# describe SubmissionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe SubmissionsHelper do
  let (:submission) {FactoryGirl.create(:submission)}
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
end
